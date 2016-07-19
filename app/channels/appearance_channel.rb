# Notify clients when users go online/offline and how many of them are named
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    # Notify clients who are not the current one that someone has come online
    # Current stats need to be sent to client before `stream_for` to avoid an error
    send_user_stats
    stream_for :global
  end

  def unsubscribed
    send_user_stats
  end

  # Available for clients to specifically ask for current users online
  def online
    send_user_stats
  end

  private

  def send_user_stats
    success :global, :online, current_users_online
  end

  def user_names(user_ids)
    User.where(id: user_ids).select(:name, :id)
  end

  # Get various stats about the number of users online.
  # This gets called a lot so use Redis cached data.
  def current_users_online
    total_count = ActionCable.server.connections.count
    users_count = Redis.current.scard(:users_online)
    user_ids = Redis.current.srandmember(:users_online, 5)
    {
      total_online: total_count,
      anonymous_online: Redis.current.get(:anonymous_online),
      users_online: users_count,
      users: user_names(user_ids)
    }
  end
end

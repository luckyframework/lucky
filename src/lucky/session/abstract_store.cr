abstract class Lucky::Session::AbstractStore
  abstract def id
  abstract def destroy
  abstract def update(other_hash)
  abstract def set_session
  abstract def current_session
end

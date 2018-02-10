defprotocol Helix.Story.Model.Steppable do
  @moduledoc """
  # The Steppable protocol

  The Steppable protocol is responsible for defining the building blocks of a
  mission.

  Remember:
    - A Storyline is made of Chapters.
    - A Chapter is made of Missions.
    - A Mission is made of Steps.

  As far as Helix is concerned, we only need Steps. Missions, Chapters and
  Storyline are an abstraction meant to the user. For the most part, these high
  level abstraction do not exist at Helix.

  Anyway, back to the Steppable protocol. A module implementing the protocol
  is representing one step within a mission.

  The Steppable is quite different from other protocols. First, it is heavily
  generated by macros, so the step specification seems like a DSL. As such,
  in order to create a Mission Step you won't map exactly all functions listed
  on this protocol. Continue to the section `Step DSL` for more information.

  # Step DSL

  ## Structure

  The Step DSL, which under the hood implements the Steppable protocol, is a bit
  different, and has some requirements. They are:

  - All steps must reside within it's Mission's module.
  - A mission module resides at `Helix.Story.Mission`

  So, if I want to create StepOne for MissionOne, it's "path" is
  `Helix.Story.Mission.MissionOne.StepOne`. This is mandatory!

  At the mission root, we can define a contact. This contact will be used by
  all steps that belong to the mission and which did not override the contact.
  The contact is defined by the macro `contact`. Contact ID should be an atom.

  Finally, you'll use the `step` macro within the Mission module. Each `step`
  macro will create the Step module, implement the Steppable protocol and add
  some default functions.

  ## Defining emails with `email`

  One must use the `email` macro to define all Contact-based emails. An email
  may have multiple possible replies, some of which may be "locked".

  Locked replies must be unlocked through game events. Unlocked replies mean
  the user can reply "at compile time", i.e. as soon as the email is received,
  without further actions.

  All email replies should be handled by the `on_reply` macro. It will generate
  a `handle_event` filter, which will look for `StoryReplySentEvent` where
  the email being responded (reply_to) and the reply_id matches the one defined
  on the `on_reply` macro.

  ## Reacting to replies with `on_reply`

  The `on_reply` macro can have 3 blocks: `send`, `complete` and `do`.

  Send means that, when a reply is received, Helix should send the specified
  email. If `:complete` is given, Helix will call the `complete/1` function. The
  `do` block means an arbitrary command will be executed.

  ## Idempotent context creation with `setup/2`

  `setup/2` is responsible for generating the entire step environment in an
  idempotent fashion. This is important because, in the case of a step restart,
  fresh data *may* need to be regenerated.

  The list of events should include all events originated by the `setup/2`
  method. So, for instance, if during the `setup/2` function we generate a file
  and a log, both corresponding events should be passed upstream, so they can be
  emitted by the StoryHandler.

  (Note that whenever someone requests a step restart, they are responsible for
  cleaning up any stale/corrupt/invalid data. `setup/2` only creates data. See
  the "Restarting a step" section for more information).

  ## Setting up a new step with `start/2`

  The `start/2` function is called when the previous step was completed, and
  this step will be marked as the player's current step. It receives both the
  current and the previous step struct (in most cases you can ignore the
  previous step).

  Its return signature is `{status, new_step, [events]}` where `status` is
  one of `:ok` | `:error` (where `:error` means something really bad happened
  internally).

  `start/2` will use the `setup/2` method to generate and prepare the step data
  and environment. Once this is done, it will also send the email to the user
  (applicable in most cases).

  ## Reacting to arbitrary events with `handle_event`

  `handle_event/3` is the secret sauce of the Steppable protocol. Any incoming
  events handled by the StoryDispatcher* will verify whether the player is in
  a step. If so, the corresponding step's `handle_event` will be called, with
  the event being passed as a parameter. As such, if the step wants to react to
  any event, it simply needs to pattern match it.

  If an event fails to be pattern matched, a fallback catch-all will return a
  :noop message, meaning that that event should be ignored.

  Pay attention to the return types of `handle_event`! The return signature is
  `{action, new_step, [events]}`, where action  may be one of:

  - :noop - Do nothing after `handle_event` is called.
  - :complete - Mark the step as completed by calling `complete/1`
  - {:restart, reason, checkpoint} - Mark the step as restarted by calling
    `restart/3`. `reason` is used to notify the player why the step got
    restarted, and `checkpoint` points to the last email that we'll rollback to.

  The `new_step` will be passed to the next functions if applicable (complete
  or restart). Any events on the list of events will always be emitted, even if
  `:noop` is the returned action.

  ## Completing a step with `complete`

  In order to complete a step, implement `complete/1`. The `complete` function
  will only be called by `on_reply`, when the `complete: true` block is used,
  or by `handle_event`, when the returned action is `complete`.

  `complete` must return a 3-tuple, `{status, new_step, [events]}`, where
  status is one of `:ok` | `:error`. `:error` means an internal error happened,
  and bad things will happen to the user.

  ## Pointing to the next step with `next_step/1`

  Steps can be seen as linked lists. One step must always point to the next step
  (with the exception of the last step, which can point to itself).

  In order to do so, simply use the `next_step` macro, passing the module name
  as argument, like `next_step Helix.Story.Mission.MissionName.StepName`

  ## Restarting a step with `restart/3`

  TODO DOCME

  ## Example

  A working example can be seen at `lib/story/mission/tutorial/steps.ex`
  """

  alias Helix.Event
  alias Helix.Story.Model.Step

  @spec start(cur_step :: Step.t, prev_step :: Step.t | nil) ::
    {:ok | :error, Step.t, [Event.t]}
  @doc """
  Function called when the previous step was completed. It has the purpose of
  setting up the new step, preparing its environment and generating any objects
  required for its functioning.

  Note that any side-effects that return events, like creating a file or
  sending an email, must be passed upstream as an accumulated list of events so
  the caller (StoryHandler) may emit all events as expected.

  `:error` should only be returned when something unexpected happened during the
  environment generation. It should be logged and debug thoroughly, since no
  errors should happen during this step.
  """
  def start(step, previous_step)

  # TODO DOCME
  def setup(step, previous_step)

  @spec handle_event(Step.t, Event.t, Step.meta) ::
    {Step.callback_action, Step.t, [Event.t]}
  @doc """
  Generic filtering of events. Any event will be pattern-matched against the
  implementations of `handle_event` of the given Step.

  The Step meta is passed as an parameter in order to ease pattern matching.

  If the returned action is `:noop`, the StepHandler will stop the flow. If
  `:complete` is returned, then `complete/1` will be called. On the other hand,
  if `{:restart, reason, checkpoint}` is returned, `restart/3` will be called.

  Note that if a step is "restartable", it must explicitly implement `restart/3`
  """
  def handle_event(step, event, meta)

  @spec complete(Step.t) ::
    {:ok | :error, Step.t, [Event.t]}
  @doc """
  Method called when the Step has been marked for completion. This can only
  happen when a specific event was matched and the returned action was
  `:complete`.

  Similar to `start/2`, `:error` should only be returned in ugly cases, in which
  the error reason should be thoroughly logged and debugged.
  """
  def complete(step)

  @spec restart(Step.t, reason :: atom, checkpoint :: Step.email_id) ::
    {:ok | :error, Step.t, [Event.t]}
  @doc """
  Method used when the step is restarted. Note that most steps are not
  restartable, and as such implementing this function is not always necessary.

  However, if you want it to be restartable, it must be explicitly implemented.

  `restart/3` is only called when a specific `handle_event` returned
  `{:restart, reason, checkpoint}` as the requested action.
  """
  def restart(step, reason, checkpoint)

  @spec next_step(Step.t) ::
    Step.step_name
  @doc """
  Points to the next step.

  Note that this function should not be implemented directly. Instead, the
  `next_step/1` macro should be used. Simply pass the next step's module as arg.

  Example:

  `next_step Helix.Story.Mission.MissionOne.StepTwo`
  """
  def next_step(step)

  @spec get_contact(Step.t) ::
    Step.contact
  @doc """
  Returns the contact name (contact_id).

  Must not be implemented nor called directly. Instead, use `Step.get_contact/1`
  """
  def get_contact(step)

  @spec format_meta(Step.t) ::
    Step.meta
  @doc """
  Converts back the step's metadata to Helix internal data structure. Since the
  metadata is stored as a JSONB on Postgres, the internal structure is lost,
  and a conversion must be done. Similar to `ProcessViewable.after_read_hook`.

  May be ignored if the step has no metadata.
  """
  def format_meta(step)

  @spec get_replies(Step.t, Step.email_id) ::
    [Step.reply_id]
  @doc """
  Returns all possible unlocked replies of an email.

  Must not be implemented nor called directly. Instead, use `Step.get_replies/1`
  """
  def get_replies(step, email_id)
end

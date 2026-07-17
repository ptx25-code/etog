defmodule ElixTogetherWeb.ClockLive do
  use ElixTogetherWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick) #-- This is an Erlang function that sets a recurring timer once, and it keeps firing forever.
    end

    socket = assign_current_time(socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

     <div  id="instructions-wrapper" phx-update="ignore">
          <div id="instructions-card" class="floating-card" data-key="clock-info">
              <header class="card-header" data-drag-handle>
                <strong class="card-title">Clock Demo Info</strong>
                <div class="card-controls">
                  <button type="button" class="control-btn" id="instr-minimise" aria-label="Minimise instructions">—</button>
                </div>
              </header>
               <p class="small">Tip: drag this floating card to move around. Your position is saved locally.</p>
          <div class="card-body" id="instr-body">
            <div class="steps">
              <span class="sentence">This page updates the time every second using LiveView’s <code>handle_info/2</code> callback.</span>
              <span class="sentence">When the client connects, the server starts a repeating timer that sends a <code>:tick</code> message once per second.
              Each tick updates the <code>@now</code> assign, and LiveView automatically patches only the time element in the DOM,
              giving you real‑time updates with no client‑side JavaScript.</span>
            </div>
             <.link href={~p"/"}> 🚚 Back to Home</.link>
          </div>
        </div>
      </div>

    <div class="flex items-center justify-center h-screen bg-[#315d95]">
      <div class="text-center">
        <h1 class="text-8xl font-extrabold text-[#b5f278] animate-pulse [text-shadow:_2px_2px_4px_rgba(0,0,0,0.5)]">🕒 {@now}</h1>
        <p class="mt-6 text-xl text-gray-300">This is the UK time (April - Oct end)</p>
      </div>
    </div>
    """
  end

  def handle_info(:tick, socket) do
    socket = assign_current_time(socket)

    {:noreply, socket}
  end

  def assign_current_time(socket) do

   now =
    Time.utc_now()
    |> Time.add(3600, :second)
    |> Time.truncate(:second)
    |> Time.to_string()

    assign(socket, now: now)
  end
end

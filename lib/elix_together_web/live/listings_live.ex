defmodule ElixTogetherWeb.ListingsLive do
  use ElixTogetherWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       submitted_notes: [],
       show_chart: false,
       chart_type: "pie",
       form: to_form(%{"content" => "", "value" => ""})
     )}
  end

  def render(assigns) do
    ~H"""
    <div id="listings-card-wrapper" phx-update="ignore">
      <div id="instructions-card" class="floating-card" data-key="listings-info">
        <header class="card-header" data-drag-handle>
          <strong class="card-title">Quietboard — Tech Overview</strong>
          <div class="card-controls">
            <button type="button" class="control-btn" id="instr-minimise">—</button>
          </div>
        </header>
     <p class="small">Tip: drag this floating card to move around. Your position is saved locally.</p>
        <div class="card-body">
          <div class="steps">
            <span class="sentence">
              This LiveView manages a dynamic list of notes using server‑side state only — no client‑side JS for form handling.
            </span>
            <span class="sentence">
              Each submission triggers a LiveView event that updates the list and pushes chart data to a JS hook.
            </span>
            <span class="sentence">
              Charts are rendered client‑side via a Phoenix hook using Chart.js, with data streamed from the server.
            </span>
            <span class="sentence">
              JSON import/export and PDF generation are handled through LiveView events and custom JS hooks.
            </span>
          </div>
        </div>
      </div>
    </div>

    <div class="min-h-screen w-full">
      <div class="w-full max-w-4xl mx-auto px-6 py-8">
       <.link href={~p"/"}> 🚚 Back to Home</.link>
        <h1 class="text-2xl font-bold mb-4">Quietboard — Phoenix LiveView, No Extras</h1>

        <div class="p-4 mb-6 rounded-lg border border-gray-300 bg-white shadow-sm">
          <p class="text-gray-700">
            A small interactive notes tool built with Elixir and Phoenix LiveView.
            It lets you add labelled entries with a value and colour, view them as a list,
            and visualise the data as bar, pie, or doughnut charts.
          </p>

          <p style="font-size: 0.9em; color: gray; margin-top: 1rem;">
            This tool is for personal use only. No data is stored or shared.
          </p>

          <p style="font-size: 0.9em; color: gray; margin-top: 0.5rem;">
            🔒 Your data stays on your device—nothing is sent anywhere. Saved files remain local.
          </p>
        </div>

        <h2 class="text-xl mb-6">Add Item and Quantity</h2>

        <.form
          for={@form}
          phx-submit="submit_note"
          class="flex flex-col md:flex-row md:items-center gap-2 w-full max-w-2xl"
        >
          <.input
            field={@form[:content]}
            placeholder="Type something..."
            class="flex-grow px-2 py-1 border rounded"
          />
          <.input
            type="number"
            field={@form[:value]}
            placeholder="Value"
            class="w-24 px-2 py-1 border rounded"
          />
          <button class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded">Submit</button>
          <select
            name="chart_type"
            phx-change="change_chart_type"
            class="ml-4 px-2 py-1 border rounded"
          >
            <option value="bar" selected={@chart_type == "bar"}>Bar</option>

            <option value="pie" selected={@chart_type == "pie"}>Pie</option>

            <option value="doughnut" selected={@chart_type == "doughnut"}>Doughnut</option>

            <option value="line" selected={@chart_type == "line"}>Line</option>
          </select>
        </.form>

        <%= if @submitted_notes != [] do %>
          <ul class="mt-4 space-y-2">
            <%= for {note, index} <- Enum.with_index(@submitted_notes) do %>
              <li class="flex items-center justify-between">
                <span>{note.content} - {note.value}</span>
                <button
                  phx-click="delete_note"
                  phx-value-index={index}
                  class="px-4 py-2 bg-teal-500 hover:bg-teal-600 text-white rounded"
                >
                  🗑️ Delete
                </button>
              </li>
            <% end %>
          </ul>
        <% end %>

        <%= if @submitted_notes != [] do %>
          <% labels = Jason.encode!(Enum.map(@submitted_notes, & &1.content)) %> <% values =
            Jason.encode!(Enum.map(@submitted_notes, & &1.value)) %> <% colors =
            Jason.encode!(Enum.map(@submitted_notes, & &1.color)) %>
          <div id="chart-container" phx-update="replace" class="mt-6">
            <canvas
              id="items-chart"
              phx-hook="ItemsChart"
              data-labels={~c"#{labels}"}
              data-values={~c"#{values}"}
              data-colors={~c"#{colors}"}
              data-chart-type={@chart_type}
              class="w-full h-64"
            >
            </canvas>
          </div>
        <% end %>

        <div class="mt-4 flex gap-4">
          <button
            type="button"
            onclick="document.getElementById('json-loader').click()"
            class="flex-1 px-3 py-2 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded shadow-sm border border-gray-400 transition-colors"
          >
            📂 Load Notes from JSON
          </button>
           <input type="file" id="json-loader" phx-hook="JsonLoader" class="hidden" />
          <button
            id="save-btn"
            phx-click="download_json"
            class="flex-1 px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded shadow-sm transition-colors"
          >
            💾 Save as JSON
          </button>
          <button
            id="export-pdf-btn"
            phx-hook="ExportPDF"
            phx-click="export_pdf"
            class="flex-1 px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded shadow-sm transition-colors"
          >
            🧾 Export to PDF
          </button>
        </div>
      </div>
    </div>
    """
  end

  # -------------------------
  # RANDOM COLOUR GENERATOR
  # -------------------------
  def random_color do
    "#" <>
      (Enum.map(1..3, fn _ ->
         (:rand.uniform(256) - 1)
         |> Integer.to_string(16)
         |> String.pad_leading(2, "0")
       end)
       |> Enum.join())
  end

  # -------------------------
  # EVENTS
  # -------------------------

  def handle_event("export_pdf", _, socket) do
    notes =
      Enum.map(socket.assigns.submitted_notes, fn n ->
        %{content: n.content, value: n.value}
      end)

    {:noreply, push_event(socket, "export_pdf", %{notes: notes})}
  end

  def handle_event("download_json", _, socket) do
    json = Jason.encode!(socket.assigns.submitted_notes)
    {:noreply, push_event(socket, "download_json", %{json: json})}
  end

  def handle_event("change_chart_type", %{"chart_type" => type}, socket) do
    {:noreply, assign(socket, chart_type: type)}
  end

  def handle_event("load_json", %{"notes" => notes}, socket) when is_list(notes) do
    cleaned_notes =
      Enum.map(notes, fn note ->
        %{
          content: Map.get(note, "content", ""),
          value: Map.get(note, "value", 0),
          color: Map.get(note, "color", random_color())
        }
      end)

    {:noreply, assign(socket, submitted_notes: cleaned_notes)}
  end

  def handle_event("load_json", _, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "submit_note",
        %{"content" => content, "value" => value, "chart_type" => chart_type},
        socket
      ) do
    note = %{
      content: content,
      value: String.to_integer(value),
      color: random_color()
    }

    {:noreply,
     socket
     |> assign(:submitted_notes, socket.assigns.submitted_notes ++ [note])
     |> assign(:chart_type, chart_type)
     |> push_event("chart_data", %{
       labels: Enum.map(socket.assigns.submitted_notes ++ [note], & &1.content),
       values: Enum.map(socket.assigns.submitted_notes ++ [note], & &1.value),
       colors: Enum.map(socket.assigns.submitted_notes ++ [note], & &1.color),
       type: chart_type
     })}
  end

  def handle_event("delete_note", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    updated_notes = List.delete_at(socket.assigns.submitted_notes, index)
    {:noreply, assign(socket, submitted_notes: updated_notes)}
  end

  def handle_event("render_chart", _params, socket) do
    {:noreply, assign(socket, :show_chart, true)}
  end
end

defmodule TodoistBot.Processor do
  alias TodoistBot.Storage
  require Logger

  def process_message(nil), do: Logger.error("Processor received nil")

  def process_message(%Nadia.Model.Update{} = message) do
    try do
      # Task.start(Botan, :track, [message])
      message
      |> TodoistBot.Interaction.new()
      |> TodoistBot.Storage.load_user()
      |> TodoistBot.Commands.match()
      |> Storage.save_user()
      |> send_response()
    rescue
      error -> Logger.warn(error)
    end
  end

  def send_notification(%TodoistBot.Interaction{} = i) do
    try do
      send_response(i)
    rescue
      error -> Logger.warn(error)
    end
  end

  def send_response(%TodoistBot.Interaction{response: response}) do
    case response.type do
      :message ->
        send_message(response)

      :edit_markup ->
        answer_callback_query(response)
        edit_message_reply_markup(response)

      :edit_text ->
        answer_callback_query(response)
        edit_message_text(response)

      :answer_callback ->
        answer_callback_query(response)
    end
  end

  defp send_message(%TodoistBot.Interaction.Response{} = response) do
    options =
      [reply_markup: response.reply_markup, parse_mode: response.parse_mode]
      |> Enum.reject(fn {_, v} -> v == nil end)

    Nadia.send_message(response.chat_id, response.text, options)
  end

  defp answer_callback_query(%TodoistBot.Interaction.Response{} = response) do
    options =
      [text: response.answer_callback_query_text]
      |> Enum.reject(fn {_, v} -> v == nil end)

    Task.start(fn -> Nadia.answer_callback_query(response.callback_query_id, options) end)
  end

  defp edit_message_reply_markup(%TodoistBot.Interaction.Response{} = response) do
    options =
      [reply_markup: response.reply_markup]
      |> Enum.reject(fn {_, v} -> v == nil end)

    Nadia.edit_message_reply_markup(response.chat_id, response.message_id, "", options)
  end

  defp edit_message_text(%TodoistBot.Interaction.Response{} = response) do
    options =
      [reply_markup: response.reply_markup, parse_mode: response.parse_mode]
      |> Enum.reject(fn {_, v} -> v == nil end)

    Nadia.edit_message_text(response.chat_id, response.message_id, "", response.text, options)
  end
end
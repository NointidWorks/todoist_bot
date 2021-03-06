defmodule TodoistBot.Interaction.Response do
  alias __MODULE__

  defstruct chat_id: nil,
            text: "",
            reply_markup: nil,
            callback_query_id: nil,
            answer_callback_query_text: nil,
            message_id: nil,
            type: :none,
            parse_mode: nil

  def new(%Nadia.Model.Update{callback_query: nil} = update) do
    %Response{
      chat_id: update.message.chat.id
    }
  end

  def new(%Nadia.Model.Update{message: nil} = update) do
    %Response{
      chat_id: update.callback_query.message.chat.id,
      callback_query_id: update.callback_query.id,
      message_id: update.callback_query.message.message_id
    }
  end
end

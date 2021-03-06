# frozen_string_literal: true

#
# Copyright (C) 2020 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

module Types
  class ConversationType < ApplicationObjectType
    graphql_name 'Conversation'

    implements GraphQL::Types::Relay::Node

    global_id_field :id
    field :_id, ID, "legacy canvas id", method: :id, null: false
    field :context_type, String, null: true
    field :context_id, Integer, null: true
    field :subject, String, null: true
    field :updated_at, Types::DateTimeType, null: true

    field :conversation_messages_connection, Types::ConversationMessageType.connection_type, null: true
    def conversation_messages_connection
      load_association(:conversation_messages).then do |messages|
        Promise.all(
          messages.map {|message| Loaders::AssociationLoader.for(ConversationMessage, :conversation_message_participants).load(message)}
        ).then do
          messages.select {|message| message.conversation_message_participants.pluck(:user_id).include?(current_user.id)}
        end
      end
    end

    field :conversation_participants_connection, Types::ConversationParticipantType.connection_type, null: true
    def conversation_participants_connection
      load_association(:conversation_participants)
    end
  end
end

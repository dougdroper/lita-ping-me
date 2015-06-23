require 'spec_helper'

RSpec.describe Lita::Handlers::PingMe, lita_handler: true do

  context '#sleep' do
    it 'with no args' do
      send_message("sleep")
      expect(replies.last).to eq("Sure, will sleep for 20 minutes")
    end

    it 'with args' do
      send_message("sleep 30")
      expect(replies.last).to eq("Sure, will sleep for 30 minutes")
    end

    it 'defaults with invalid args' do
      send_message("sleep xxx")
      expect(replies.last).to eq("Sure, will sleep for 20 minutes")
    end
  end

  context '#status' do
    let(:current_status) do
        {
          'http://www.example.com/search' => { code: 500, time: 4.882903 },
          'http://www.example.com/other'  => { code: 200, time: 6.882903 },
          'http://www.example.com/about'  => { code: 503, time: 2.882    }
        }
    end

    let(:response) { double(current_status: current_status) }

    context 'default urls' do
      let(:expected) do
        <<-END
         http://www.example.com/search: code 500, time: 4.882903
         http://www.example.com/other: code 200, time: 6.882903
         http://www.example.com/about: code 503, time: 2.882
        END
      end

      before do
        expect(Lita::Handlers::Connection).to receive(:new).and_return(response)
      end

      it 'responds with the correct status' do
        send_message('status')
        expect(replies.last).to eq(expected.split("\n").map(&:strip).join("\n"))
      end

      it 'checks for errors' do
        send_message('any errors?')
        expect(replies).to include("http://www.example.com/search is down: {:code=>500, :time=>4.882903}")
        expect(replies).to include("http://www.example.com/about is down: {:code=>503, :time=>2.882}")
      end
    end

    context 'custom url' do
      let(:current_status) { {'http://test.com' => { code: 200, time: 4.882903 }} }

      it 'responds with the correct status' do
        expect(Lita::Handlers::Connection).to receive(:new).with(["http://test.com"]).and_return(response)
        send_message("status <http://test.com|test.com>")
        expect(replies.last).to eq("http://test.com: code 200, time: 4.882903")
      end
    end
  end
end

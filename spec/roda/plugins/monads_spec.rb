# frozen_string_literal: true

RSpec.describe Roda::RodaPlugins::Monads, roda: :plugin, name: :monads do
  route do |r|
    r.on('value') { Success('Alright') }
    r.on('status') { Failure(:unauthorized) }
    r.on 'rack' do
      r.on 'symbol' do
        r.on('right') { Success([:ok, {}, 'OK']) }
        r.on('left') { Failure([:found, { 'Location' => '/rack_right' }, nil]) }
      end
      r.on('right') { Success([200, {}, 'OK']) }
      r.on('left') { Failure([:unauthorized, {}, nil]) }
    end
    r.on('neither') { 'neither' }
  end

  it { expect(described_class).to be_a Module }

  describe 'Roda class' do
    subject { roda_class }

    it { is_expected.to respond_to :either_matcher }
    include_context 'Monads shortcuts'
  end

  describe 'Roda instance' do
    subject { roda_instance }

    include_context 'Monads shortcuts'
  end

  describe 'Roda' do
    subject { last_response }

    describe 'value matcher' do
      before { get '/value' }

      it { is_expected.to be_successful }
      its(:body) { is_expected.to eq 'Alright' }
    end

    describe 'status matcher' do
      before { get '/status' }

      it { is_expected.not_to be_successful }
      its(:body) { is_expected.to eq '' }
    end

    context 'rack' do
      describe 'right matcher' do
        before { get '/rack/right' }

        it { is_expected.to be_successful }
        its(:body) { is_expected.to eq 'OK' }
      end

      describe 'left matcher' do
        before { get '/rack/left' }

        it { is_expected.not_to be_successful }
        it { is_expected.to be_unauthorized }
        its(:body) { is_expected.to eq '' }
      end

      describe 'symbol' do
        describe 'right matcher' do
          before { get '/rack/symbol/right' }

          it { is_expected.to be_ok }
          its(:body) { is_expected.to eq 'OK' }
        end

        describe 'left matcher' do
          before { get '/rack/symbol/left' }

          it { is_expected.not_to be_successful }
          it { is_expected.to be_redirect }
          its(:body) { is_expected.to eq '' }
        end
      end
    end

    describe 'not a monad' do
      before { get '/neither' }

      it { is_expected.to be_successful }
      its(:body) { is_expected.to eq 'neither' }
    end
  end
end

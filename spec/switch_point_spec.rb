RSpec.describe SwitchPoint do
  describe '.writable!' do
    after do
      SwitchPoint.readonly!(:main)
    end

    it 'changes connection globally' do
      expect(Book).to connect_to('main_readonly.sqlite3')
      expect(Publisher).to connect_to('main_readonly.sqlite3')
      SwitchPoint.writable!(:main)
      expect(Book).to connect_to('main_writable.sqlite3')
      expect(Publisher).to connect_to('main_writable.sqlite3')
    end

    it 'affects thread-globally' do
      SwitchPoint.writable!(:main)
      Thread.start do
        expect(Book).to connect_to('main_writable.sqlite3')
      end.join
    end

    context 'within with block' do
      it 'changes the current mode' do
        Book.with_writable do
          SwitchPoint.readonly!(:main)
          expect(Book).to connect_to('main_readonly.sqlite3')
        end
        expect(Book).to connect_to('main_readonly.sqlite3')
        Book.with_writable do
          expect(Book).to connect_to('main_writable.sqlite3')
        end
      end
    end
  end

  describe '.with_writable' do
    it 'changes connection' do
      SwitchPoint.with_writable(:main, :nanika1) do
        expect(Book).to connect_to('main_writable.sqlite3')
        expect(Publisher).to connect_to('main_writable.sqlite3')
        expect(Nanika1).to connect_to('default.sqlite3')
      end
      expect(Book).to connect_to('main_readonly.sqlite3')
      expect(Publisher).to connect_to('main_readonly.sqlite3')
      expect(Nanika1).to connect_to('main_readonly.sqlite3')
    end
  end
end

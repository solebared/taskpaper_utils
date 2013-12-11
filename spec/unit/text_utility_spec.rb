require 'spec_helper'

module TaskpaperUtils
  describe TextUtils do
    include TextUtils

    describe '#strip_leave_indents:' do
      it 'strips line terminators' do
        expect(strip_leave_indents "a line\n").to eql 'a line'
      end

      it 'strips leading and trailing spaces' do
        expect(strip_leave_indents '  spacious  ').to eql 'spacious'
      end

      it 'preservs leading tabs' do
        expect(strip_leave_indents "\tstill indented!").to eql "\tstill indented!"
      end
    end
  end
end

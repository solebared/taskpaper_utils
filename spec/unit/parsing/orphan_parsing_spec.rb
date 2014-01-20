require 'spec_helper'

describe 'Document with notes and tasks outside of projects' do
  include SpecHelpers

  let(:document) do
    parse(
      "a note
       - a task
       another note
       a project:
       - with a task")
  end

  it 'adopts the unowned entries' do
    # todo: expand into individual specs
    expect(document).to have(4).entries
    expect(document.notes.map(&:text)).to eq ['a note', 'another note']
    expect(document).to have(1).tasks
    expect(document).to have(1).projects
  end

end

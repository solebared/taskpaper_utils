require 'spec_helper'

module TaskpaperUtils
  describe EntryContainer do
    include ParsingHelpers

    let(:project) { new_entry('project:') }

    describe 'Enumerability' do

      before do
        project << new_entry('- task')
        project << new_entry('- ksat')
      end

      it 'is Enumerable' do
        expect(project).to be_a(Enumerable)
      end

      it 'exposes an #each method' do
        # Enumerable#map depends on each being implemented
        expect(project.map(&:text)).to eq %w(task ksat)
      end

    end

    describe '#dump' do

      it "yields it's raw text" do
        expect { |b| new_entry('a task').dump(&b) }.to yield_with_args 'a task'
      end

      it "provides it's children's raw text to the collector" do
        project << new_entry("\t- task")
        project << new_entry("\t\t- subtask")
        expect { |b| project.dump(&b) }
        .to yield_successive_args 'project:', "\t- task", "\t\t- subtask"
      end

      describe "when it doesn't have any text" do
        it "skips itself but yields it's children" do
          document = Document.new
          document << new_entry("\t- one")
          document << new_entry("\t- two")
          expect { |b| document.dump(&b) }
          .to yield_successive_args "\t- one", "\t- two"
        end
      end
    end

    describe '#children of type' do

      it 'finds children of the specified type' do
        task = project << new_entry("\t- task")
        note = project << new_entry("\ta note")
        expect(project.children_of_type(:task)).to include task
        expect(project.children_of_type(:task)).to_not include note
      end

    end

    describe '#size' do
      specify '#size returns the number of child entries' do
        expect { project << new_entry('e') }.to change(project, :size).by(1)
      end
    end

    describe '#add_entry, #<<' do

      specify "adding a child entry sets it's parent" do
        task = project.add_entry new_entry('- task')
        expect(task.parent).to eq(project)
      end

      it 'is aliased as <<' do
        expect { project << new_entry('e') }.to change(project, :size)
      end

    end

    describe '#last' do

      it 'returns nil if the entry has no children' do
        expect(project.last).to be_nil
      end

      it 'returns the entry added last' do
        project << new_entry('1')
        project << new_entry('2')
        expect(project.last.text).to eq('2')
      end

    end

    describe '#[]' do

      let!(:note)   { project << new_entry('a note') }

      it 'finds a child referenced by text' do
        expect(project['a note']).to eq(note)
      end

      # see specs for Entry#matches? for detailed cases
    end

    describe 'tagged' do

      let(:project_a) { document['project a'] }
      let(:project_b) { document['project b'] }
      let(:document) do
        parse_doc("project a:
                   \t- task without tags
                   \t- task with @tag
                   project b: @tag
                   \t- parent task
                   \t\t- subtask with @tag
                   project c:
                   \t- parent with @tag @in @c
                   \t\t- subtask also with @tag")
      end

      it 'finds children with the given tag' do
        expect(project_a.tagged('tag').map(&:text)).to eq(['task with'])
      end

      describe 'nested matches' do

        # note: we use .map(&:text) here because it verifies both the size and
        # contents of the tagged entries

        it 'finds matching nested children' do
          expect(project_b.tagged(:tag).map(&:text)).to eq(['subtask with'])
        end

        it 'does not dig into children of a matching parent' do
          # 'parent with @tag @in @c', but not 'subtask also with @tag'
          expect(document['project c'].tagged(:tag).map(&:text)).to eq(['parent with'])
        end

        it 'combines matching entries from different levels of the doc' do
          expect(document.tagged(:tag).map(&:text_with_trailing_tags))
            .to eq(['task with @tag', 'project b: @tag', 'parent with @tag @in @c'])
        end
      end
    end
  end
end

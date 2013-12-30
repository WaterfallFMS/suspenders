require 'spec_helper'

describe LinkHelper do
  before       {helper.stub can?: true}
  let(:object) {build :forum}

  context '.show_link' do
    it 'returns empty if user cannot show object' do
      helper.stub :can? do |perm|
        case perm
          when :show then false
          else true
        end
      end

      expect(helper.show_link(object)).to be_blank
    end

    it 'returns a link to the object' do
      link = helper.show_link(object)
      expect(link).to include '<a href'
      expect(link).to include helper.url_for(object)
    end

    it 'returns a link to the link, if provided' do
      link = helper.show_link(object,'foo')
      expect(link).to include 'href="foo"'
    end
  end

  context '.new_link' do
    it 'returns empty if user cannot new object' do
      helper.stub :can? do |perm|
        case perm
          when :new then false
          else true
        end
      end

      expect(helper.new_link(object.class,object)).to be_blank
    end

    it 'returns a link to the link' do
      link = helper.new_link(object.class,'foo')
      expect(link).to include '<a href="foo"'
    end
  end

  context '.edit_link' do
    it 'returns empty if user cannot show object' do
      helper.stub :can? do |perm|
        case perm
          when :edit then false
          else true
        end
      end

      expect(helper.edit_link(object,object)).to be_blank
    end

    it 'returns a link to the link' do
      link = helper.edit_link(object,'foo')
      expect(link).to include '<a href="foo"'
    end
  end

  context '.destroy_link' do
    it 'returns empty if user cannot destroy object' do
      helper.stub :can? do |perm|
        case perm
          when :destroy then false
          else true
        end
      end

      expect(helper.destroy_link(object)).to be_blank
    end

    it 'returns a link to the object' do
      link = helper.destroy_link(object)
      expect(link).to include '<a href'
      expect(link).to include helper.url_for(object)
    end

    it 'returns a link to the link, if provided' do
      link = helper.destroy_link(object,'foo')
      expect(link).to include 'href="foo"'
    end
  end
end
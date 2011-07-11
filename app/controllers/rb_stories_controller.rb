include RbCommonHelper

class RbStoriesController < RbApplicationController
  unloadable
  include BacklogsCards
  
  def index
    cards = Cards.new(params[:sprint_id] ? @sprint.stories : RbStory.product_backlog(@project), params[:sprint_id], current_language)
    
    respond_to do |format|
      format.pdf { send_data(cards.pdf.render, :disposition => 'attachment', :type => 'application/pdf') }
    end
  end
  
  def create
    params['author_id'] = User.current.id
    story = RbStory.create_and_position(params)
    status = (story.id ? 200 : 400)
    
    respond_to do |format|
      format.html { render :partial => "story", :object => story, :status => status }
    end
  end

  def update
    story = RbStory.find(params[:id])
    result = story.update_and_position!(params)
    story.reload
    status = (result ? 200 : 400)
    
    respond_to do |format|
      format.html { render :partial => "story", :object => story, :status => status }
    end
  end

end

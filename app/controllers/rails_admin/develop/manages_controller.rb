class RailsAdmin::Develop::ManagesController < RailsAdmin::Develop::ApplicationController

  before_filter :find_params, except: %w(update create new)

  def index
    @version = RailsAdmin::Client.conn.origin_query("SELECT Version() as version").each
  end


  def query
    @entries = RailsAdmin::Client.query(RailsAdmin::Client.query_str,@page, @per).each  if RailsAdmin::Client.query_str
  rescue Exception => e
    RailsAdmin::Client.query_str = @q
    flash[:errors] = e.message
  end

  def filter
    RailsAdmin::Client.query_str = params[:q]
    redirect_to action: :query
  end

  def show
    @query_str = "SELECT * FROM #{params[:id]}"
    @query_str = RailsAdmin::Client.compose(params) if params[:field].present?
    @fields = RailsAdmin::Client.desc_table params[:id]
    @entries = RailsAdmin::Client.query(@query_str,@page, @per)
  rescue Exception => e
    flash[:errors] = e.message
  end

  def new;end

  def edit; end

  def edit_column
    @fields = RailsAdmin::Client.desc_table params[:id]
  end

  def details
    @details = RailsAdmin::Client.conn.origin_query("SHOW TABLE STATUS LIKE '#{params[:id]}'").each
  end

  def create
    RailsAdmin::Client.insert(params[:table_name], params[:field])
    flash[:success] = "成功添加#{params[:table_name]}一条数据。"
  rescue Exception => e
    flash[:errors] = e.message
  ensure
    redirect_to develop_manage_path(params[:table_name])
  end

  def update
    RailsAdmin::Client.update(params[:table_name], params[:id], params[:field])
    flash[:success] = "更新#{params[:id]}内容成功。"
  rescue Exception => e
    flash[:errors] = e.message
  ensure
    redirect_to develop_manage_path(params[:table_name])
  end


  def update_field
    RailsAdmin::Client.conn.origin_query("UPDATE #{params[:table]} SET #{params[:field]} = REPLACE(REPLACE(REPLACE('#{params[:value]}', '&','&amp;'), '>', '&gt;'), '<', '&lt;') WHERE id = #{params[:id]}")
    render text: 'success'
  end

  def destroy
    RailsAdmin::Client.delete(params[:id], params[:edit_id]) if params[:edit_id].present?
    render json: params[:edit_id]
  end

  private

  def find_params
    @page, @per = (params[:page] || 1).to_i, (params[:per] || 100).to_i
  end

end
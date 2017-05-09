module FitnessTracker

  module Helpers
  
    def logged_in?
      !!session[:id]
    end

    def current_user
      User.find_by(id: session[:id])
    end

    def first_name(name)
      name.split(" ")[0]
    end

    def recent_exercises(user)
      user.exercises.limit(6)
    end

    def recent_meals(user)
      user.foods.limit(6)
    end

    def print_time(datetime)
      ordinal_suffix = ""
      case datetime.localtime.day % 10
        when 0,4,5,6,7,8,9
          ordinal_suffix = "th"
        when 1
          ordinal_suffix = "st"
        when 2
          ordinal_suffix = "nd"
        when 3
          ordinal_suffix = "rd"
      end
      datetime.localtime.strftime("%B %-d<sup>#{ordinal_suffix}</sup>, %Y")
    end

    def attr_display_str(obj, attrs_to_display)
      attr_string = attrs_to_display.collect {|attr| obj.send(attr).to_s}.join(" - ")
    end

    def viewing_own_profile_while_logged_in?(user)
      if logged_in?
       user.id == current_user.id
      else
        false
      end
    end

    def display_all_obj_associations_by_date(user, obj_association, *attrs_to_display)
      output_buffer = ""
      first_two = user.foods.first(2)
      if first_two.size >= 1
        iterator_start = first_two[1].id if first_two.size == 2
        current_date = print_time(first_two[0].created_at)
        output_buffer << <<-HTML
        <div class="row">
        <div class="col-sm-3 col-sm-offset-0 card-style">
        <h3>#{current_date}</h3>
        <a href="/#{obj_association}/#{first_two[0].id}">#{attr_display_str(first_two[0],attrs_to_display)}</a>
        HTML
        column_inserted_count = 1
        if first_two.size == 2
          user.send(obj_association).find_each(start: iterator_start) do |obj|
            if current_date != print_time(obj.created_at)
              current_date = print_time(obj.created_at)
              if column_inserted_count % 4 == 0
                output_buffer << <<-HTML
                </div>
                </div>
                <div class="row">
                <div class="col-sm-3 card-style">
                <h3>#{current_date}</h3>
                <a href="/#{obj_association}/#{obj.id}">#{attr_display_str(obj,attrs_to_display)}</a>
                HTML
                column_inserted_count += 1
              else
                output_buffer << <<-HTML
                </div>
                <div class="col-sm-3 col-sm-offset-1 card-style">
                <h3>#{current_date}</h3>
                <a href="/#{obj_association}/#{obj.id}">#{attr_display_str(obj,attrs_to_display)}</a>
                HTML
                column_inserted_count += 1
              end
            else
              output_buffer << <<-HTML
              <a href="/#{obj_association}/#{obj.id}">#{attr_display_str(obj,attrs_to_display)}</a>
              HTML
            end
          end
        end
        output_buffer << <<-HTML
        </div>
        </div>
        HTML
      end
      output_buffer
    end

    def profile_pic_path(user)
      profile_pic_file = Dir.glob(File.join("images","users","#{user.id}","profile_pic.*")).first.match(/(?<=\/)profile_pic.+/)[0]
      url("images/users/#{user.id}/#{profile_pic_file}")
    end
  end

end
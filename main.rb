require 'rubygems'
require 'gosu'

module ZOrder
  Background, Graphics, Text, UI = *0..100
end

class TextField < Gosu::TextInput
  INACTIVE_COLOR  = 0xcc666666
  ACTIVE_COLOR    = 0xff666666
  SELECTION_COLOR = 0xcc0000ff
  CARET_COLOR     = 0xffffffff
  PADDING = 5

  attr_reader :x, :y

  def initialize(window, font, x, y)
    super()

    @window, @font, @x, @y = window, font, x, y

    self.text = "Input Answer Here"
  end

  def filter(text)
    text.downcase
  end


  def draw
    if @window.text_input == self then
      background_color = ACTIVE_COLOR
    else
      background_color = INACTIVE_COLOR
    end
    @window.draw_quad(x - PADDING,         y - PADDING,          background_color,
                      x + width + PADDING, y - PADDING,          background_color,
                      x - PADDING,         y + height + PADDING, background_color,
                      x + width + PADDING, y + height + PADDING, background_color, 0)

    pos_x = x + @font.text_width(self.text[0...self.caret_pos])
    sel_x = x + @font.text_width(self.text[0...self.selection_start])

    @window.draw_quad(sel_x, y,          SELECTION_COLOR,
                      pos_x, y,          SELECTION_COLOR,
                      sel_x, y + height, SELECTION_COLOR,
                      pos_x, y + height, SELECTION_COLOR, 0)

    if @window.text_input == self then
      @window.draw_line(pos_x, y,          CARET_COLOR,
                        pos_x, y + height, CARET_COLOR, 0)
    end

    @font.draw(self.text, x, y, 0)
  end

  def width
    @font.text_width(self.text)
  end

  def height
    @font.height
  end

  def under_point?(mouse_x, mouse_y)
    mouse_x > x - PADDING and mouse_x < x + width + PADDING and
        mouse_y > y - PADDING and mouse_y < y + height + PADDING
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 640, 400, false
    self.caption = 'Music Guessing Game'

    @black_background_image = Gosu::Image.new("media/background.jpg", :tileable => true)
    @white_background_image = Gosu::Image.new("media/white_music_background.jpg", :tileable => true)
    @exit_background = Gosu::Image.new("media/music_background2.png", :tileable => true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 24)
    @heading_font = Gosu::Font.new(self, "French Script MT", 90)
    @answer_font = Gosu::Font.new(self, "Mistral", 50)

    @play1 = Gosu::Image.from_text("PLAY", 90, options = {:font => "Broadway"})
    @play_song = Gosu::Image.from_text("<u>Play the song</u>", 60, options = {:font => "Mistral"})
    @title = Gosu::Image.from_text("<b>Can you guess the song?</b>", 90, options = {:font => "French Script MT", :width => 350, :align => :center})

    @round_num = 0

    @next_word = Gosu::Image.from_text("NEXT", 50, options = {:font => "Centaur"})
    @next = false

    @final_points = Gosu::Image.from_text("Points: #{@round_num}", 50, options = {:font => "Mistral"})
    @final_points_font = Gosu::Font.new(self, "Mistral", 50)

    @you_lose = Gosu::Image.from_text("YOU LOSE", 90, options = {:font => "Broadway"})
    @you_win = Gosu::Image.from_text("YOU WIN", 90, options = {:font => "Broadway"})

    @play_again = Gosu::Image.from_text()

    @let_it_go = Gosu::Sample.new('media/let_it_go.wav')
    @bad_blood = Gosu::Sample.new('media/bad blood.wav')
    @pop_songs = [[@let_it_go, "let it go"], [@bad_blood, "bad blood"]].shuffle
    @play_button = Gosu::Image.new('media/play.jpg', :tileable => false)

    @start = 0
    @keya_pressed = false
    @next_screen = 0
    @answered = false
    @points = 0
    @lose = false
    @win = false

    @text_field = TextField.new(self, @font, 300, 250)
  end

  def update
  end

  def button_down (id)
    case id
      when Gosu::MsLeft
        if mouse_x > 340 && mouse_x < 595 && mouse_y < 335 && mouse_y > 250
          @start = 1
        end
        if mouse_x > 155 && mouse_x < 195 && mouse_y < 190 && mouse_y > 150
          if @start
            song = @pop_songs[@round_num][0]
            song.play
          end
        end
        if mouse_x > 420 && mouse_x < 600 && mouse_y < 375 && mouse_y > 315
          if @text_field.text == @pop_songs[@round_num][1]
            @answered = true
            @points += 1
          elsif @text_field.text != @pop_songs[@round_num][1] && @text_field.text != "Input Answer Here"
            @start = 2
            @lose = true
          end

          if @answered == true
            @next = true
            @round_num += 1
            if @round_num == 2
              @win = true
              @start = 2
            end
          end
        end
    end

    if id == Gosu::MsLeft && @text_field.under_point?(mouse_x, mouse_y) then
      self.text_input = @text_field
    end
  end

  def needs_cursor?
    true
  end

  def draw
    if @start == 0
      @black_background_image.draw(0, 0, ZOrder::Background)
      @title.draw(280, 30, ZOrder::Text, 1, 1, Gosu::Color::YELLOW)
      @play1.draw(350, 245, ZOrder::Text, 1, 1, Gosu::Color::FUCHSIA)
      draw_quad(340, 250, 0xff00ffff, 595, 250, 0xffffffff, 340, 335, 0xff00ff00, 595, 335, 0xff00ffff, ZOrder::Graphics)
    end

    if @start == 1
      @white_background_image.draw(0, 0, ZOrder::Background)
      @play_song.draw(200, 140, ZOrder::Text, 1, 1, Gosu::Color::BLACK)

      @heading_font.draw("<b>Round #{@round_num + 1}</b>", 200, 30, ZOrder::Text, 1, 1, 0xff00ff00, mode = :default)
      draw_quad(75, 35, 0xffff0000, 560, 35, 0xffff00ff, 75, 110, 0xffff0000, 560, 110, 0xffff00ff, ZOrder::Graphics)
      draw_quad(155, 150, 0xffff0000, 195, 150, 0xffff00ff, 195, 190, 0xffff0000, 155, 190, 0xffff00ff, ZOrder::Graphics)
      @play_button.draw(155, 150, ZOrder::Graphics)

      @answer_font.draw("Answer:", 175, 235, ZOrder::Text, 1, 1, Gosu::Color::BLACK, mode = :default)
      @text_field.draw

      @next_word.draw(450, 320, ZOrder::Text, 1, 1, Gosu::Color::BLUE)
      draw_quad(420, 315, 0xff00ffff, 600, 315, 0xffffffff, 420, 375, 0xff00ff00, 600, 375, 0xff00ffff, ZOrder::Graphics)

      @font.draw("Points: #{@round_num}", 10, 370, ZOrder::Text, 1, 1, Gosu::Color::BLACK, mode = :default)
    end

    if @lose || @win
      @exit_background.draw(0, 0, ZOrder::Background)
      # @final_points.draw(440, 200, ZOrder::Text)
      @final_points_font.draw("Points: #{@round_num}", 440, 200, ZOrder::Text, 1, 1, Gosu::Color::WHITE, mode = :default)
      if @lose
      @you_lose.draw(110, 80, ZOrder::Text)
      elsif @win
        @you_win.draw(120, 80, ZOrder::Text)
      end
    end
    # if @keya_pressed
    #   @font.draw("a", 10, 30, 1.0, 1.0, 1.0)
    # end

    # draw_quad(x-size, y-size, 0xffffffff, x+size, y-size, 0xffffffff, x-size, y+size, 0xffffffff, x+size, y+size, 0xffffffff, 0)
    # draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3, z=0, mode=:default)
    # draw_line(x1, y1, c1, x2, y2, c2, z=0, mode=:default)
    # @font.draw("This should be <c=ffff00>yellow</c> => this part changes the text inside to that color", 10, 10, 1.0, 1.0, 1.0, Gosu::Color::BLUE => this changes entire text)
    # @font.draw("This should be <b>bold</b>", 10, 30, 1.0, 1.0, 1.0)
    # @font.draw("This should be <i>italic</i>", 10, 50, 1.0, 1.0, 1.0)
    # @font.draw("This should be <u>underlined</u>", 10, 70, 1.0, 1.0, 1.0)
  end
end

window = GameWindow.new
window.show

# text fields from http://oflute.googlecode.com/svn/tutGosu/ejemplo/gosu/examples/TextInput.rb
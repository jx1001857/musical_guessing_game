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

    @black_background_image = Gosu::Image.new("images/background.jpg", :tileable => true)
    @white_background_image = Gosu::Image.new("images/white_music_background.jpg", :tileable => true)
    @exit_background = Gosu::Image.new("images/music_background2.png", :tileable => true)
    @music_background = Gosu::Image.new("images/music.jpg")

    @font = Gosu::Font.new(self, Gosu::default_font_name, 24)
    @heading_font = Gosu::Font.new(self, "French Script MT", 90)
    @answer_font = Gosu::Font.new(self, "Mistral", 50)
    @levels_font = Gosu::Font.new(self, "Harlow Solid Italic", 100)
    @wrong_answer_font = Gosu::Font.new(self, "Times New Roman", 25)

    @play1 = Gosu::Image.from_text("PLAY", 90, options = {:font => "Broadway"})
    @play_song = Gosu::Image.from_text("<u>Play the song</u>", 60, options = {:font => "Mistral"})
    @title = Gosu::Image.from_text("<b>Can you guess the song?</b>", 90, options = {:font => "French Script MT", :width => 350, :align => :center})

    @easy = Gosu::Image.from_text("guess artist or song title", 50, options = {:font => "Harlow Solid Italic", :width => 400})
    @hard = Gosu::Image.from_text("guess song title", 50, options = {:font => "Harlow Solid Italic", :width => 400})

    @round_num = 0

    @next_word = Gosu::Image.from_text("NEXT", 50, options = {:font => "Centaur"})
    @next = false

    @final_points = Gosu::Image.from_text("Points: #{@round_num}", 50, options = {:font => "Mistral"})

    @you_lose = Gosu::Image.from_text("YOU LOSE", 90, options = {:font => "Broadway"})
    @you_win = Gosu::Image.from_text("YOU WIN!", 90, options = {:font => "Broadway"})

    @play_again = Gosu::Image.from_text("Play Again?", 50, options = {:font => "Harlow Solid Italic"})

    @let_it_go = Gosu::Song.new('songs/let_it_go.wav')
    @bad_blood = Gosu::Song.new('songs/bad blood.wav')
    @thousand_years = Gosu::Song.new('songs/a thousand years.wav')
    @all_of_me = Gosu::Song.new('songs/all of me.wav')
    @wrecking_ball = Gosu::Song.new('songs/wrecking ball.wav')
    @thinking_out_loud = Gosu::Song.new('songs/thinking out loud.wav')
    @say_something = Gosu::Song.new('songs/say something.wav')
    @demons = Gosu::Song.new('songs/demons.wav')
    @call_me_maybe = Gosu::Song.new('songs/call me maybe.wav')
    @centuries = Gosu::Song.new('songs/centuries.wav')
    @counting_stars = Gosu::Song.new('songs/counting stars.wav')
    @heartbeat_song = Gosu::Song.new('songs/heartbeat song.wav')
    @let_her_go = Gosu::Song.new('songs/let her go.wav')
    @love_the_way_you_lie = Gosu::Song.new('songs/love the way you lie.wav')
    @pompeii = Gosu::Song.new('songs/pompeii.wav')
    @rolling_in_the_deep = Gosu::Song.new('songs/rolling in the deep.wav')
    @royals = Gosu::Song.new('songs/royals.wav')
    @stay_with_me = Gosu::Song.new('songs/stay with me.wav')
    @story_of_my_life = Gosu::Song.new('songs/story of my life.wav')
    @take_me_to_church = Gosu::Song.new('songs/take me to church.wav')
    @wake_me_up = Gosu::Song.new('songs/wake me up.wav')
    @my_immortal = Gosu::Song.new('songs/my immortal.wav')

    @pop_songs = [[@let_it_go, "let it go", "idina menzel"],
                  [@bad_blood, "bad blood", "taylor swift"],
                  [@thousand_years, "a thousand years", "christina perri"],
                  [@all_of_me, "all of me", "john legend"],
                  [@wrecking_ball, "wrecking ball", "miley cyrus"],
                  [@thinking_out_loud, "thinking out loud", "ed sheeran"],
                  [@say_something, "say something", "a great big world", "christina aguilera"],
                  [@demons, "demons", "imagine dragons"],
                  [@call_me_maybe, "call me maybe", "carly rae jepsen"],
                  [@centuries, "centuries", "fall out boy"],
                  [@counting_stars, "counting stars", "onerepublic"],
                  [@heartbeat_song, "heartbeat song", "kelly clarkson"],
                  [@let_her_go, "let her go", "passenger"],
                  [@love_the_way_you_lie, "love the way you lie", "eminem", "feat. rihanna"],
                  [@pompeii, "pompeii", "bastille"],
                  [@rolling_in_the_deep, "rolling in the deep", "adele"],
                  [@royals, "royals", "lorde"],
                  [@stay_with_me, "stay with me", "sam smith"],
                  [@story_of_my_life, "story of my life", "one direction"],
                  [@take_me_to_church, "take me to church", "hozier"],
                  [@wake_me_up, "wake me up", "avicii"],
                  [@my_immortal, "my immortal", "evanescence"]
                  ].shuffle

    @play_button = Gosu::Image.new('images/play.jpg', :tileable => false)

    @start = 0
    @keya_pressed = false
    @next_screen = 0
    @answered = false
    @lose = false
    @win = false
    @first_time_play = true
    @listen = false

    @text_field = TextField.new(self, @font, 330, 250)
  end

  def button_down (id)
    case id
      when Gosu::MsLeft
        if @first_time_play
          if mouse_x > 340 && mouse_x < 595 && mouse_y < 335 && mouse_y > 250
            @start = 1
            @first_time_play = false
          end
        end

        if @change == 0
          if mouse_x > 74 && mouse_x < 346 && mouse_y > 91 && mouse_y < 177
            @level = "easy"
            @start = 5
            @change = 1
          elsif mouse_x > 226 && mouse_x < 535 && mouse_y > 243 && mouse_y < 326
            @level = "hard"
            @start = 5
            @change = 1
          end
        end

        if mouse_x > 155 && mouse_x < 195 && mouse_y < 190 && mouse_y > 150
          if @start == 5
            @song = @pop_songs[@round_num][0]
            @song.play
            @listen = true
          end
        end

        if @round_num < @pop_songs.count && !@lose && !@win
          if @listen
            if mouse_x > 420 && mouse_x < 600 && mouse_y < 375 && mouse_y > 315
              if @level == "hard"
                if @text_field.text == @pop_songs[@round_num][1]
                  @answered = true
                elsif @text_field.text != @pop_songs[@round_num][1] && @text_field.text != "Input Answer Here"
                  @start = 2
                  @lose = true
                  @song.stop

                  @wrong_answer = @pop_songs.dup
                  @answer = @wrong_answer[@round_num]
                  @answer.shift
                  @string_answer = @answer.join(', ')
                end
              elsif @level == "easy"
                if @pop_songs[@round_num].include?(@text_field.text)
                  @answered = true
                elsif !@pop_songs[@round_num].include?(@text_field.text) && @text_field.text != "Input Answer Here"
                  @start = 2
                  @lose = true
                  @song.stop

                  @wrong_answer = @pop_songs.dup
                  @answer = @wrong_answer[@round_num]
                  @answer.shift
                  @string_answer = @answer.join(', ')
                end
              end

              if @answered
                @song.stop
                @next = true
                @round_num += 1
                if @round_num == @pop_songs.count
                  @win = true
                  @start = 2
                end
              end
            end
          end
        end

        if @start == 3
          if mouse_x > 320 && mouse_x < 535 && mouse_y > 287 && mouse_y < 330
            @start = 0
            @lose = false; @win = false
            @first_time_play = true
            @listen = false
            @round_num = 0
            @pop_songs = [[@let_it_go, "let it go", "idina menzel"],
                          [@bad_blood, "bad blood", "taylor swift"],
                          [@thousand_years, "a thousand years", "christina perri"],
                          [@all_of_me, "all of me", "john legend"],
                          [@wrecking_ball, "wrecking ball", "miley cyrus"],
                          [@thinking_out_loud, "thinking out loud", "ed sheeran"],
                          [@say_something, "say something", "a great big world", "christina aguilera"],
                          [@demons, "demons", "imagine dragons"],
                          [@call_me_maybe, "call me maybe", "carly rae jepsen"],
                          [@centuries, "centuries", "fall out boy"],
                          [@counting_stars, "counting stars", "onerepublic"],
                          [@heartbeat_song, "heartbeat song", "kelly clarkson"],
                          [@let_her_go, "let her go", "passenger"],
                          [@love_the_way_you_lie, "love the way you lie", "eminem", "feat. rihanna"],
                          [@pompeii, "pompeii", "bastille"],
                          [@rolling_in_the_deep, "rolling in the deep", "adele"],
                          [@royals, "royals", "lorde"],
                          [@stay_with_me, "stay with me", "sam smith"],
                          [@story_of_my_life, "story of my life", "one direction"],
                          [@take_me_to_church, "take me to church", "hozier"],
                          [@wake_me_up, "wake me up", "avicii"],
                          [@my_immortal, "my immortal", "evanescence"]].shuffle
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
      @music_background.draw(0, 0, ZOrder::Background)
      @levels_font.draw("EASY", 75, 75, ZOrder::Text, 1, 1, Gosu::Color::FUCHSIA)
      @easy.draw(75, 165, ZOrder::Text, 1, 1, Gosu::Color::GREEN)
      @levels_font.draw("HARD", 225, 225, ZOrder::Text, 1, 1, Gosu::Color::FUCHSIA)
      @hard.draw(225, 305, ZOrder::Text, 1, 1, Gosu::Color::GREEN)
      @change = 0
    end

    if @start == 5
      @white_background_image.draw(0, 0, ZOrder::Background)
      @play_song.draw(200, 140, ZOrder::Text, 1, 1, Gosu::Color::BLACK)

      @heading_font.draw("<b>Round #{@round_num + 1}</b>", 200, 30, ZOrder::Text, 1, 1, 0xff00ff00, mode = :default)
      draw_quad(75, 35, 0xffff0000, 560, 35, 0xffff00ff, 75, 110, 0xffff0000, 560, 110, 0xffff00ff, ZOrder::Graphics)
      draw_quad(155, 150, 0xffff0000, 195, 150, 0xffff00ff, 195, 190, 0xffff0000, 155, 190, 0xffff00ff, ZOrder::Graphics)
      @play_button.draw(155, 150, ZOrder::Graphics)

      @answer_font.draw("Name of song:", 120, 235, ZOrder::Text, 1, 1, Gosu::Color::BLACK, mode = :default)
      @text_field.draw

      @next_word.draw(450, 320, ZOrder::Text, 1, 1, Gosu::Color::BLUE)
      draw_quad(420, 315, 0xff00ffff, 600, 315, 0xffffffff, 420, 375, 0xff00ff00, 600, 375, 0xff00ffff, ZOrder::Graphics)

      @font.draw("Points: #{@round_num}", 10, 370, ZOrder::Text, 1, 1, Gosu::Color::BLACK, mode = :default)
    end

    if @win || @lose
      @exit_background.draw(0, 0, ZOrder::Background)
      @answer_font.draw("Points: #{@round_num}", 100, 280, ZOrder::Text, 1, 1, Gosu::Color::WHITE, mode = :default)
      @play_again.draw(320, 280, ZOrder::Graphics)
      if @lose
        @you_lose.draw(110, 15, ZOrder::Text)
        @wrong_answer_font.draw("Answer to missed song:", 10, 330, ZOrder::Text, 1, 1, Gosu::Color::WHITE, mode = :default)
        @wrong_answer_font.draw("#{@string_answer}", 10, 360, ZOrder::Text, 1, 1, Gosu::Color::WHITE, mode = :default)

      elsif @win
        @you_win.draw(125, 15, ZOrder::Text)
      end

      @start = 3
    end
  end
end

window = GameWindow.new
window.show

# text box from http://oflute.googlecode.com/svn/tutGosu/ejemplo/gosu/examples/TextInput.rb
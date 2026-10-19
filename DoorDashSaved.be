# @name    DoorDashSaved
# @desc    Money saved this month by skipping DoorDash, and what it grows to
# @author  monad-droid
# @version 1.1
# @config  monthly number "Monthly average"    default=681.34 min=0 max=99999 step=0.01 unit=$ help="Your average monthly DoorDash spend"
# @config  rate    number "Growth rate"        default=15 min=0 max=100 step=0.1 unit=% group=Future
# @config  years   number "Years"              default=30 min=1 max=100 group=Future
# @config  flip    number "Flip every"         default=4 min=1 max=30 unit=s help="Seconds before switching views"
# @config  tint    color  "Savings color"      default=#3CDC5A
# @config  gold    color  "Future color"       default=#FFD700 group=Future
# @config  bar     bool   "Month progress bar" default=true

# Page 1 - saved so far = monthly / days in this month * today's date.
#   Oct 1 -> 21.98, Oct 19 -> 417.60, Oct 31 -> 681.34, then it starts over.
# Page 2 - one month's spend compounded yearly: monthly * (1 + rate)^years.
#   681.34 at 15% for 30 years -> 45,113.

import math

class DoorDashSaved
  var msg      # page 1 text, e.g. "417.60"
  var future   # page 2 text, e.g. "45,113"
  var fill     # progress bar length in pixels
  var tint, gold
  var flip_ms
  var shown_at
  var ticks

  def init()
    self.msg = nil
    self.fill = 0
    self.tint = store.get("tint")
    self.gold = store.get("gold")
    self.flip_ms = int(num(store.get("flip"), 4) * 1000)
    self.shown_at = 0
    self.ticks = 0
    var grown = num(store.get("monthly"), 0) * math.pow(1 + num(store.get("rate"), 0) / 100.0, num(store.get("years"), 0))
    self.future = self.money(grown)
  end

  # Fits in the 23 px beside the icon: 45,113 / 452K / 4.5M
  def money(v)
    if v >= 1000000
      return format("%.1fM", v / 1000000.0)
    elif v >= 100000
      return str(int(v / 1000 + 0.5)) + "K"
    elif v >= 1000
      var n = int(v + 0.5)
      return str(n / 1000) + "," + format("%03d", n % 1000)
    end
    return str(int(v + 0.5))
  end

  # Days since a fixed point; the difference of two gives days between dates.
  def day_number(y, m, d)
    if m <= 2
      y -= 1
    end
    var era = y / 400
    var yoe = y - era * 400
    var mp = m > 2 ? m - 3 : m + 9
    var doy = (153 * mp + 2) / 5 + d - 1
    return era * 146097 + yoe * 365 + yoe / 4 - yoe / 100 + doy
  end

  def loop()
    if self.ticks <= 0
      self.ticks = 60
      if year() > 0
        var y = year()
        var m = month()
        var ny = m == 12 ? y + 1 : y
        var nm = m == 12 ? 1 : m + 1
        var days = self.day_number(ny, nm, 1) - self.day_number(y, m, 1)
        var saved = num(store.get("monthly"), 0) / days * day()
        self.msg = format("%.2f", saved)
        self.fill = store.get("bar") ? (23 * day()) / days : 0
      end
    end
    self.ticks -= 1
  end

  def on_show()
    self.shown_at = now_ms()
  end

  # stay long enough to show both views once
  def duration()
    return self.flip_ms * 2
  end

  def draw()
    clear()
    var future = ((now_ms() - self.shown_at) / self.flip_ms) % 2 == 1

    if future
      # rising chart with an arrowhead
      var g = self.gold != nil ? self.gold : 0xFFD700
      line(0, 6, 2, 4, g)
      line(2, 4, 4, 5, g)
      line(4, 5, 7, 1, g)
      line(5, 1, 7, 1, g)
      line(7, 1, 7, 3, g)
      text(9 + (23 - text_ink_width(self.future)) / 2, 6, self.future, g)
      return
    end

    # piggy bank, facing right, with a gold coin above the slot
    rect_fill(1, 1, 4, 1, 0xFF7FA0)
    pixel(6, 1, 0xFF7FA0)
    rect_fill(0, 2, 7, 3, 0xFF7FA0)
    rect_fill(1, 5, 6, 1, 0xFF7FA0)
    pixel(1, 6, 0xFF7FA0)
    pixel(6, 6, 0xFF7FA0)
    pixel(5, 3, 0x000000)
    rect_fill(7, 3, 1, 2, 0xD9506E)
    pixel(3, 0, 0xFFD700)

    var c = self.tint != nil ? self.tint : settings.get("textColor")
    if self.msg == nil
      text(11, 6, "...", 0x666666)
      return
    end
    text(9 + (23 - text_ink_width(self.msg)) / 2, 6, self.msg, c)
    if self.fill > 0
      line(9, 7, 31, 7, 0x0F3316)
      line(9, 7, 8 + self.fill, 7, c)
    end
  end
end

return DoorDashSaved()

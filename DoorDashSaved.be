# @name    DoorDashSaved
# @desc    Money saved this month by skipping DoorDash
# @author  david
# @version 1.0
# @config  monthly number "Monthly average" default=681.34 min=0 max=99999 step=0.01 unit=$ help="Your average monthly DoorDash spend"
# @config  tint    color  "Number color"    default=#3CDC5A
# @config  bar     bool   "Month progress bar" default=true

# Saved so far = monthly / days in this month * today's date.
# Oct 1 -> 21.98, Oct 19 -> 417.60, Oct 31 -> 681.34, then it starts over.

class DoorDashSaved
  var msg      # the number to draw, e.g. "417.60"
  var fill     # progress bar length in pixels
  var tint
  var ticks

  def init()
    self.msg = nil
    self.fill = 0
    self.tint = store.get("tint")
    self.ticks = 0
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

  def draw()
    clear()
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

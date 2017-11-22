class ItemWrapper < SimpleDelegator
  def offset_quality!(v = 1)
    new_quality = quality + v
    return unless (0..50).cover?(new_quality)
    __getobj__.quality = new_quality
  end

  def age!
    __getobj__.sell_in -= 1
  end

  def degradation_rate
    sell_in.negative? ? -2 : -1
  end

  def update!
    age!
    offset_quality!(degradation_rate)
  end

  def self.match?(item)
    item.name == self::NAME
  end
end

class SulfurasWrapper < ItemWrapper
  NAME = 'Sulfuras, Hand of Ragnaros'
  def update!;end
end

class AgedBrieWrapper < ItemWrapper
  NAME = 'Aged Brie'
  def update!
    age!
    offset_quality!(sell_in.negative? ? 2 : 1)
  end
end

class BackStagePassesWrapper < ItemWrapper
  NAME = 'Backstage passes to a TAFKAL80ETC concert'
  def offset_quality_amount
    if sell_in <= -1
      -quality
    elsif (5..9).cover?(sell_in)
      2
    elsif (0..4).cover?(sell_in)
      3
    else
      1
    end
  end

  def update!
    age!
    offset_quality!(offset_quality_amount)
  end
end

module WrapperFactory
  WRAPPERS = [
    SulfurasWrapper,
    AgedBrieWrapper,
    BackStagePassesWrapper
  ].freeze

  def self.build(item)
    wrapper = (WRAPPERS.find { |w| w.match?(item) } || ItemWrapper).new(item)
  end
end

def update_item(item)
  WrapperFactory.build(item).update!
end

def update_quality(items)
  items.each { |item| update_item(ItemWrapper.new(item)) }
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]


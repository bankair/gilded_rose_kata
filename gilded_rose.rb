class ItemWrapper < SimpleDelegator
  def restore!(v = 1)
    return if __getobj__.quality >= 50
    __getobj__.quality += v
    yield if block_given?
  end

  def degrade!(v = 1)
    return unless quality.positive?
    return if sulfuras?
    __getobj__.quality -= v
  end

  AGED_BRIE = 'Aged Brie'
  BACKSTAGE_PASSES = 'Backstage passes to a TAFKAL80ETC concert'
  SULFURAS = 'Sulfuras, Hand of Ragnaros'

  def age!
    return if sulfuras?
    __getobj__.sell_in -= 1
  end

  def sulfuras?
    name == SULFURAS
  end
end

def update_aged_brie(item)
  item.age!
  item.restore!(item.sell_in.negative? ? 2 : 1)
end

def update_backstage_passes(item)
  if item.sell_in <= 0
    item.quality = 0
  elsif (6..10).cover?(item.sell_in)
    item.restore!(2)
  elsif (0..5).cover?(item.sell_in)
    item.restore!(3)
  else
    item.restore!
  end
  item.age!
end

def update_standard(item)
  item.age!
  item.degrade!(item.sell_in.negative? ? 2 : 1)
end

def update_item(item)
  case item.name
  when ItemWrapper::AGED_BRIE
    update_aged_brie(item)
  when ItemWrapper::BACKSTAGE_PASSES
    update_backstage_passes(item)
  else
    update_standard(item)
  end
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


unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)

###*
Returns a copy of the array without null and undefined values.
 
@name compact
@methodOf Array#
@type Array
@returns An array that contains only the non-null values.
###
unless Array::compact
  Array::compact = () ->
    this.filter (element) ->
      element?

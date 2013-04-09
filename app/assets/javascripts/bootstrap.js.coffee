jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  window.prettyPrint && prettyPrint()

jQuery ->
  $nav = $('.subnav')
  navTop = $('.subnav').length && $('.subnav').offset().top - 40
  isFixed = 0

  processScroll = ->
    scrollTop = $(window).scrollTop()
    if scrollTop >= navTop && !isFixed
      isFixed = 1
      $nav.addClass('subnav-fixed')
    else if scrollTop <= navTop && isFixed
      isFixed = 0
      $nav.removeClass('subnav-fixed')

  processScroll()

  $(window).scroll ->
    processScroll()

jQuery ->
  $('[rel=tooltip]').tooltip()
  $('[rel=popover]').popover(placement: 'top', trigger: 'click')

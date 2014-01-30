jQuery ->
  $('.datetimepicker').after('<div class="add-on"><i class="icon-th"></i></div>')
  start_time = $('.datetimepicker').data('startdatetime')
  end_time = $('.datetimepicker').data('enddatetime')
  $('.datetimepicker').datetimepicker({
    format: 'yyyy-mm-dd hh:ii',
    startDate: start_time,
    endDate: end_time,
    minuteStep: 15,
    autoclose: true,
    startView: 3,
  })

# Override Rails handling of confirmation

$.rails.allowAction = (link) ->
  # The message is something like "Are you sure?"
  message = link.attr('confirm')
  # If there's no message, there's no data-confirm attribute, 
  # which means there's nothing to confirm
  return true unless message

  # Create the modal box with the message
  modal_html = """
               <div class="modal" id="confirmationDialog">
                 <div class="modal-dialog" role="document">
                   <div class="modal-content">
                     <div class="modal-header">
                       <h5 clas="modal-title">#{message}</h3>
                       <a class="close" data-dismiss="modal"><span>&times;</span></a>
                     </div>
                     <div class="modal-body">
                       <p>Be certain, this cannot be undone.</p>
                     </div>
                     <div class="modal-footer">
                       <a data-dismiss="modal" class="btn">Cancel</a>
                       <a data-dismiss="modal" class="btn btn-danger confirm">Yes, I'm positively certain.</a>
                     </div>
                   </div>
                 </div>
               </div>
               """
  $modal_html = $(modal_html)
  # Add the new button to the modal box
  # Pop it up
  $modal_html.modal()
  $('#confirmationDialog .confirm').on('click', ->
    console.log(link)
    $.rails.confirmed(link)
    false
  )
  # Prevent the original link from working
  false

$.rails.confirmed = (link) ->
  link.removeAttr('confirm')
  link.trigger('click.rails')

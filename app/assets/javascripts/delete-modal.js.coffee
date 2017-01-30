# Override Rails handling of confirmation

$.rails.allowAction = (link) ->
  console.log("FOO!")
  # The message is something like "Are you sure?"
  message = link.data('confirm')
  # If there's no message, there's no data-confirm attribute, 
  # which means there's nothing to confirm
  console.log(link)
  return true unless message
  console.log("BAR!")
  # Clone the clicked element (probably a delete link) so we can use it in the dialog box.
  $link = link.clone()
    # We don't necessarily want the same styling as the original link/button.
    .removeAttr('class')
    # We don't want to pop up another confirmation (recursion)
    .removeAttr('data-confirm')
    # We want a button
    .addClass('btn').addClass('btn-danger')
    # We want it to sound confirmy
    .html("Yes, I'm positively certain.")

  # Create the modal box with the message
  modal_html = """
               <div class="modal" id="myModal">
                 <div class="modal-dialog" role="document">
                   <div class="modal-content">
                     <div class="modal-header">
                       <a class="close" data-dismiss="modal"><span>&times;</span></a>
                       <h5 clas="modal-title">#{message}</h3>
                     </div>
                     <div class="modal-body">
                       <p>Be certain, sonny.</p>
                     </div>
                     <div class="modal-footer">
                       <a data-dismiss="modal" class="btn">Cancel</a>
                     </div>
                   </div>
                 </div>
               </div>
               """
  $modal_html = $(modal_html)
  # Add the new button to the modal box
  $modal_html.find('.modal-footer').append($link)
  # Pop it up
  $modal_html.modal()
  # Prevent the original link from working
  return false

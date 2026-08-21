INTERFACE zif_mail_sender PUBLIC.

  TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Send a list to somebody</p>
  "!
  "! Behind an interface because sending is the one part of a report that
  "! talks to the world outside the system, and because a test that has to
  "! read SOST to find out what a report did is not a test anybody keeps.
  "!
  "! @parameter iv_to          | <p class="shorttext synchronized">Where it goes</p>
  "! @parameter iv_subject     | <p class="shorttext synchronized">What it is about</p>
  "! @parameter it_line        | <p class="shorttext synchronized">The lines of it</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">It could not be sent</p>
  METHODS send
    IMPORTING
      iv_to      TYPE string
      iv_subject TYPE string
      it_line    TYPE ty_line_tab
    RAISING
      zcx_allocation.

ENDINTERFACE.

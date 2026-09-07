CLASS cl_stub_mail DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_content_tab  TYPE STANDARD TABLE OF solisti1 WITH EMPTY KEY.
    TYPES ty_receiver_tab TYPE STANDARD TABLE OF somlreci1 WITH EMPTY KEY.

    "! What one call to SO_NEW_DOCUMENT_SEND_API1 was given.
    TYPES:
      BEGIN OF ty_sent,
        subject  TYPE sodocchgi1-obj_descr,
        type     TYPE so_obj_tp,
        commit   TYPE abap_bool,
        content  TYPE ty_content_tab,
        receiver TYPE ty_receiver_tab,
      END OF ty_sent.
    TYPES ty_sent_tab TYPE STANDARD TABLE OF ty_sent WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Take a document as sent and keep it</p>
    "!
    "! Carries the part of SAPoffice the custom code depends on: a document
    "! with recipients goes, and what went can be read back.
    "!
    "! @parameter is_document  | <p class="shorttext synchronized">Document attributes</p>
    "! @parameter iv_type      | <p class="shorttext synchronized">Document class</p>
    "! @parameter iv_commit    | <p class="shorttext synchronized">Whether the caller asked for a commit</p>
    "! @parameter it_content   | <p class="shorttext synchronized">The lines of the document</p>
    "! @parameter it_receiver  | <p class="shorttext synchronized">Who it goes to</p>
    CLASS-METHODS send
      IMPORTING
        is_document TYPE sodocchgi1
        iv_type     TYPE so_obj_tp
        iv_commit   TYPE abap_bool
        it_content  TYPE ty_content_tab
        it_receiver TYPE ty_receiver_tab.

    "! <p class="shorttext synchronized">Everything sent so far</p>
    "!
    "! @parameter rt_sent | <p class="shorttext synchronized">One entry per document</p>
    CLASS-METHODS sent
      RETURNING
        VALUE(rt_sent) TYPE ty_sent_tab.

    "! <p class="shorttext synchronized">Forget everything sent so far</p>
    CLASS-METHODS forget.

  PRIVATE SECTION.

    CLASS-DATA gt_sent TYPE ty_sent_tab.

ENDCLASS.


CLASS cl_stub_mail IMPLEMENTATION.

  METHOD send.

    APPEND VALUE #(
      subject  = is_document-obj_descr
      type     = iv_type
      commit   = iv_commit
      content  = it_content
      receiver = it_receiver ) TO gt_sent.

  ENDMETHOD.

  METHOD sent.
    rt_sent = gt_sent.
  ENDMETHOD.

  METHOD forget.
    CLEAR gt_sent.
  ENDMETHOD.

ENDCLASS.

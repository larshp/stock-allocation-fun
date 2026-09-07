CLASS zcl_mail_sender DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_mail_sender.

    "! A plain text document, which is what a list of lines is.
    CONSTANTS c_type TYPE so_obj_tp VALUE 'RAW'.

    "! `SOMLRECI1-REC_TYPE`: an internet address rather than a SAP user.
    CONSTANTS c_internet TYPE somlreci1-rec_type VALUE 'U'.

    "! What the document is called in SOST, before the subject.
    CONSTANTS c_name TYPE sodocchgi1-obj_name VALUE 'ZSTOCKALLOC'.

ENDCLASS.


CLASS zcl_mail_sender IMPLEMENTATION.

  METHOD zif_mail_sender~send.

    DATA lt_content  TYPE STANDARD TABLE OF solisti1 WITH EMPTY KEY.
    DATA lt_receiver TYPE STANDARD TABLE OF somlreci1 WITH EMPTY KEY.
    DATA ls_document TYPE sodocchgi1.

    IF iv_to IS INITIAL.
      RETURN.
    ENDIF.

    ls_document-obj_name  = c_name.
    ls_document-obj_descr = iv_subject.
    ls_document-obj_langu = sy-langu.

    LOOP AT it_line INTO DATA(lv_line).
      APPEND VALUE #( line = lv_line ) TO lt_content.
    ENDLOOP.

    APPEND VALUE #( receiver = iv_to
                    rec_type = c_internet ) TO lt_receiver.

    " the send is committed by the function module itself: a report that sent
    " a list and did not commit has queued a document that never leaves, and
    " there is nothing else in this unit of work to lose
    CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
      EXPORTING
        document_data              = ls_document
        document_type              = c_type
        commit_work                = abap_true
      TABLES
        object_content             = lt_content
        receivers                  = lt_receiver
      EXCEPTIONS
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        OTHERS                     = 5.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>not_sent
        mv_message = |{ iv_to }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

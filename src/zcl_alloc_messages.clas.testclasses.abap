CLASS ltcl_alloc_messages DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_messages.

    METHODS setup.

    METHODS message
      IMPORTING
        iv_msgty      TYPE c
        iv_text       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_messages=>ty_message.

    METHODS input
      IMPORTING
        it_messages   TYPE zcl_alloc_messages=>ty_message_tt
        is_message    TYPE zcl_alloc_messages=>ty_message
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_messages=>ty_input.

    METHODS collects_message FOR TESTING.
    METHODS skips_empty_text FOR TESTING.
    METHODS keeps_previous   FOR TESTING.
    METHODS counts_messages  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_messages IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_messages( ).
  ENDMETHOD.

  METHOD message.
    rs_row-msgty = iv_msgty.
    rs_row-msgid = 'ZALLOC'.
    rs_row-msgno = '001'.
    rs_row-text = iv_text.
  ENDMETHOD.

  METHOD input.
    rs_row-messages = it_messages.
    rs_row-message = is_message.
  ENDMETHOD.

  METHOD collects_message.
    DATA lt_messages TYPE zcl_alloc_messages=>ty_message_tt.

    DATA(lt_new) = mo_cut->collect(
      input( it_messages = lt_messages
             is_message  = message( iv_msgty = 'E'
                                    iv_text  = 'Run failed' ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-msgty exp = 'E' ).
  ENDMETHOD.

  METHOD skips_empty_text.
    DATA lt_messages TYPE zcl_alloc_messages=>ty_message_tt.

    DATA(lt_new) = mo_cut->collect(
      input( it_messages = lt_messages
             is_message  = message( iv_msgty = 'I'
                                    iv_text  = '' ) ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_new ).
  ENDMETHOD.

  METHOD keeps_previous.
    DATA lt_messages TYPE zcl_alloc_messages=>ty_message_tt.

    DATA(lt_first) = mo_cut->collect(
      input( it_messages = lt_messages
             is_message  = message( iv_msgty = 'I'
                                    iv_text  = 'Started' ) ) ).

    DATA(lt_second) = mo_cut->collect(
      input( it_messages = lt_first
             is_message  = message( iv_msgty = 'E'
                                    iv_text  = 'Failed' ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_second ) exp = 2 ).
  ENDMETHOD.

  METHOD counts_messages.
    DATA lt_messages TYPE zcl_alloc_messages=>ty_message_tt.

    lt_messages = mo_cut->collect(
      input( it_messages = lt_messages
             is_message  = message( iv_msgty = 'I'
                                    iv_text  = 'Started' ) ) ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( lt_messages )
                                        exp = 1 ).
  ENDMETHOD.

ENDCLASS.

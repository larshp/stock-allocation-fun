CLASS ltcl_alloc_msg_format DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_msg_format.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_msgty      TYPE c
        iv_msgno      TYPE c
        iv_text       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_msg_format=>ty_input.

    METHODS formats_full   FOR TESTING.
    METHODS formats_short  FOR TESTING.
    METHODS handles_empty  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_msg_format IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_msg_format( ).
  ENDMETHOD.

  METHOD input.
    rs_row-msgty = iv_msgty.
    rs_row-msgid = 'ZALLOC'.
    rs_row-msgno = iv_msgno.
    rs_row-text = iv_text.
  ENDMETHOD.

  METHOD formats_full.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->format( input( iv_msgty = 'E'
                                   iv_msgno = '001'
                                   iv_text  = 'Run failed' ) )
      exp = 'E ZALLOC 001 Run failed' ).
  ENDMETHOD.

  METHOD formats_short.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->short( input( iv_msgty = 'E'
                                  iv_msgno = '001'
                                  iv_text  = 'Run failed' ) )
      exp = 'E001' ).
  ENDMETHOD.

  METHOD handles_empty.
    DATA lv_text TYPE string.

    lv_text = mo_cut->format( input( iv_msgty = 'I'
                                     iv_msgno = '002'
                                     iv_text  = '' ) ).

    " the trailing blank separator survives an empty message text
    cl_abap_unit_assert=>assert_equals( act = strlen( lv_text ) exp = 13 ).
    cl_abap_unit_assert=>assert_equals(
      act = find( val = lv_text sub = 'I ZALLOC 002' ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.

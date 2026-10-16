CLASS ltcl_alloc_id_gen DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_id_gen.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_prefix     TYPE c
        iv_number     TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_id_gen=>ty_input.

    METHODS pads_to_four   FOR TESTING.
    METHODS keeps_longer   FOR TESTING.
    METHODS zero_number    FOR TESTING.
    METHODS empty_prefix   FOR TESTING.
    METHODS prefix_is_kept FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_id_gen IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_id_gen( ).
  ENDMETHOD.

  METHOD input.
    rs_row-prefix = iv_prefix.
    rs_row-number = iv_number.
  ENDMETHOD.

  METHOD pads_to_four.
    DATA lv_actual TYPE string.

    lv_actual = mo_cut->generate( input( iv_prefix = 'RUN'
                                         iv_number = 7 ) ).

    cl_abap_unit_assert=>assert_equals( act = lv_actual exp = 'RUN0007' ).
  ENDMETHOD.

  METHOD keeps_longer.
    DATA lv_actual TYPE string.

    lv_actual = mo_cut->generate( input( iv_prefix = 'R'
                                         iv_number = 12345 ) ).

    cl_abap_unit_assert=>assert_equals( act = lv_actual exp = 'R12345' ).
  ENDMETHOD.

  METHOD zero_number.
    DATA lv_actual TYPE string.

    lv_actual = mo_cut->generate( input( iv_prefix = 'X'
                                         iv_number = 0 ) ).

    cl_abap_unit_assert=>assert_equals( act = lv_actual exp = 'X0000' ).
  ENDMETHOD.

  METHOD empty_prefix.
    DATA lv_actual TYPE string.

    lv_actual = mo_cut->generate( input( iv_prefix = ''
                                         iv_number = 5 ) ).

    cl_abap_unit_assert=>assert_equals( act = lv_actual exp = '0005' ).
  ENDMETHOD.

  METHOD prefix_is_kept.
    DATA lv_actual TYPE string.

    lv_actual = mo_cut->generate( input( iv_prefix = 'WERKS'
                                         iv_number = 42 ) ).

    cl_abap_unit_assert=>assert_equals( act = lv_actual exp = 'WERKS0042' ).
  ENDMETHOD.

ENDCLASS.

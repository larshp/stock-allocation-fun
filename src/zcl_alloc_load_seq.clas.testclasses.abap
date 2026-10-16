CLASS ltcl_alloc_load_seq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_load_seq.
    DATA mt_uni TYPE zcl_alloc_load_seq=>ty_unit_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id      TYPE string
        iv_weight  TYPE i
        iv_fragile TYPE abap_bool.

    METHODS heavy_first   FOR TESTING.
    METHODS fragile_last  FOR TESTING.
    METHODS fragile_light FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_load_seq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_load_seq( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_unit TYPE zcl_alloc_load_seq=>ty_unit.

    ls_unit-unit_id = iv_id.
    ls_unit-weight = iv_weight.
    ls_unit-fragile = iv_fragile.
    APPEND ls_unit TO mt_uni.
  ENDMETHOD.

  METHOD heavy_first.
    DATA lt_units TYPE zcl_alloc_load_seq=>ty_unit_tt.

    add( iv_id = 'U1' iv_weight = 10 iv_fragile = abap_false ).
    add( iv_id = 'U2' iv_weight = 30 iv_fragile = abap_false ).

    lt_units = mo_cut->order( mt_uni ).

    cl_abap_unit_assert=>assert_equals( act = lt_units[ 1 ]-unit_id exp = 'U2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_units[ 2 ]-unit_id exp = 'U1' ).
  ENDMETHOD.

  METHOD fragile_last.
    DATA lt_units TYPE zcl_alloc_load_seq=>ty_unit_tt.

    add( iv_id = 'HEAVY' iv_weight = 10 iv_fragile = abap_false ).
    add( iv_id = 'FRAG' iv_weight = 100 iv_fragile = abap_true ).

    lt_units = mo_cut->order( mt_uni ).

    cl_abap_unit_assert=>assert_equals( act = lt_units[ 1 ]-unit_id exp = 'HEAVY' ).
    cl_abap_unit_assert=>assert_equals( act = lt_units[ 2 ]-unit_id exp = 'FRAG' ).
  ENDMETHOD.

  METHOD fragile_light.
    DATA lt_units TYPE zcl_alloc_load_seq=>ty_unit_tt.

    add( iv_id = 'F2' iv_weight = 30 iv_fragile = abap_true ).
    add( iv_id = 'F1' iv_weight = 10 iv_fragile = abap_true ).

    lt_units = mo_cut->order( mt_uni ).

    cl_abap_unit_assert=>assert_equals( act = lt_units[ 1 ]-unit_id exp = 'F1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_units[ 2 ]-unit_id exp = 'F2' ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_units TYPE zcl_alloc_load_seq=>ty_unit_tt.

    lt_units = mo_cut->order( mt_uni ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_units ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.

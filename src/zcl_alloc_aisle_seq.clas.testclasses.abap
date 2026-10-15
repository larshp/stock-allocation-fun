CLASS ltcl_alloc_aisle_seq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_aisle_seq.
    DATA mt_ais TYPE zcl_alloc_aisle_seq=>ty_aisles_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_aisle TYPE i.

    METHODS above_then_below FOR TESTING.
    METHODS start_included   FOR TESTING.
    METHODS empty_list       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_aisle_seq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_aisle_seq( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_aisle TO mt_ais.
  ENDMETHOD.

  METHOD above_then_below.
    DATA lt_order TYPE zcl_alloc_aisle_seq=>ty_aisles_tt.

    add( iv_aisle = 8 ).
    add( iv_aisle = 2 ).
    add( iv_aisle = 5 ).
    add( iv_aisle = 1 ).

    lt_order = mo_cut->sequence( it_aisles = mt_ais iv_start = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lt_order[ 1 ] exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_order[ 2 ] exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = lt_order[ 3 ] exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_order[ 4 ] exp = 1 ).
  ENDMETHOD.

  METHOD start_included.
    DATA lt_order TYPE zcl_alloc_aisle_seq=>ty_aisles_tt.

    add( iv_aisle = 7 ).

    lt_order = mo_cut->sequence( it_aisles = mt_ais iv_start = 7 ).

    cl_abap_unit_assert=>assert_equals( act = lt_order[ 1 ] exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_order ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_order TYPE zcl_alloc_aisle_seq=>ty_aisles_tt.

    lt_order = mo_cut->sequence( it_aisles = mt_ais iv_start = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_order ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.

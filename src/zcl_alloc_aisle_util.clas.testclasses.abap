CLASS ltcl_alloc_aisle_util DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_aisle_util.
    DATA mt_bin TYPE zcl_alloc_aisle_util=>ty_bin_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_aisle TYPE i
        iv_used  TYPE i
        iv_cap   TYPE i.

    METHODS sums_per_aisle FOR TESTING.
    METHODS utilisation    FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_aisle_util IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_aisle_util( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_bin TYPE zcl_alloc_aisle_util=>ty_bin.

    ls_bin-aisle = iv_aisle.
    ls_bin-used = iv_used.
    ls_bin-capacity = iv_cap.
    APPEND ls_bin TO mt_bin.
  ENDMETHOD.

  METHOD sums_per_aisle.
    DATA lt_aisles TYPE zcl_alloc_aisle_util=>ty_aisle_tt.

    add( iv_aisle = 1 iv_used = 10 iv_cap = 50 ).
    add( iv_aisle = 1 iv_used = 20 iv_cap = 50 ).
    add( iv_aisle = 2 iv_used = 5 iv_cap = 20 ).

    lt_aisles = mo_cut->analyse( it_bins = mt_bin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_aisles ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_aisles[ 1 ]-aisle exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_aisles[ 1 ]-used exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = lt_aisles[ 1 ]-capacity exp = 100 ).
  ENDMETHOD.

  METHOD utilisation.
    DATA lt_aisles TYPE zcl_alloc_aisle_util=>ty_aisle_tt.

    add( iv_aisle = 1 iv_used = 25 iv_cap = 100 ).

    lt_aisles = mo_cut->analyse( it_bins = mt_bin ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_aisles[ 1 ]-utilisation exp = 25 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_aisles TYPE zcl_alloc_aisle_util=>ty_aisle_tt.

    lt_aisles = mo_cut->analyse( it_bins = mt_bin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_aisles ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_alloc_bin_replenish DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_replenish.

    METHODS setup.

    METHODS bin
      IMPORTING
        iv_lgort      TYPE lgort_d
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bin_replenish=>ty_bin.

    METHODS input
      IMPORTING
        it_bins       TYPE zcl_alloc_bin_replenish=>ty_bin_tt
        iv_reorder    TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bin_replenish=>ty_input.

    METHODS empty_bins    FOR TESTING.
    METHODS below_reorder FOR TESTING.
    METHODS at_reorder    FOR TESTING.
    METHODS above_reorder FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bin_replenish IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_replenish( ).
  ENDMETHOD.

  METHOD bin.
    rs_row-lgort = iv_lgort.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD input.
    rs_row-bins = it_bins.
    rs_row-reorder_point = iv_reorder.
  ENDMETHOD.

  METHOD empty_bins.
    DATA lt_bins TYPE zcl_alloc_bin_replenish=>ty_bin_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->propose( input( it_bins    = lt_bins
                                    iv_reorder = '10' ) ) ).
  ENDMETHOD.

  METHOD below_reorder.
    DATA lt_bins TYPE zcl_alloc_bin_replenish=>ty_bin_tt.

    APPEND bin( iv_lgort = 'L1' iv_quantity = '4' ) TO lt_bins.

    DATA(lt_lines) = mo_cut->propose( input( it_bins    = lt_bins
                                             iv_reorder = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-shortfall exp = '6' ).
  ENDMETHOD.

  METHOD at_reorder.
    DATA lt_bins TYPE zcl_alloc_bin_replenish=>ty_bin_tt.

    APPEND bin( iv_lgort = 'L1' iv_quantity = '10' ) TO lt_bins.

    DATA(lt_lines) = mo_cut->propose( input( it_bins    = lt_bins
                                             iv_reorder = '10' ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_lines ).
  ENDMETHOD.

  METHOD above_reorder.
    DATA lt_bins TYPE zcl_alloc_bin_replenish=>ty_bin_tt.

    APPEND bin( iv_lgort = 'L1' iv_quantity = '25' ) TO lt_bins.

    DATA(lt_lines) = mo_cut->propose( input( it_bins    = lt_bins
                                             iv_reorder = '10' ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_lines ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_alloc_consolidation DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_consolidation.

    METHODS setup.

    METHODS bin
      IMPORTING
        iv_lgort      TYPE lgort_d
        iv_qty        TYPE menge_d
        iv_capacity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_consolidation=>ty_item.

    METHODS input
      IMPORTING
        it_bins       TYPE zcl_alloc_consolidation=>ty_item_tt
        iv_threshold  TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_consolidation=>ty_input.

    METHODS empty_bins     FOR TESTING.
    METHODS low_bin        FOR TESTING.
    METHODS full_bin_kept  FOR TESTING.
    METHODS zero_capacity  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_consolidation IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_consolidation( ).
  ENDMETHOD.

  METHOD bin.
    rs_row-lgort = iv_lgort.
    rs_row-quantity = iv_qty.
    rs_row-capacity = iv_capacity.
  ENDMETHOD.

  METHOD input.
    rs_row-bins = it_bins.
    rs_row-threshold_pct = iv_threshold.
  ENDMETHOD.

  METHOD empty_bins.
    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->propose( input( it_bins      = VALUE #( )
                                    iv_threshold = 20 ) ) ).
  ENDMETHOD.

  METHOD low_bin.
    DATA lt_bins TYPE zcl_alloc_consolidation=>ty_item_tt.

    APPEND bin( iv_lgort = 'L1' iv_qty = '10' iv_capacity = '100' )
      TO lt_bins.

    DATA(lt_lines) = mo_cut->propose( input( it_bins      = lt_bins
                                             iv_threshold = 20 ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-lgort exp = 'L1' ).
  ENDMETHOD.

  METHOD full_bin_kept.
    DATA lt_bins TYPE zcl_alloc_consolidation=>ty_item_tt.

    APPEND bin( iv_lgort = 'L1' iv_qty = '80' iv_capacity = '100' )
      TO lt_bins.

    DATA(lt_lines) = mo_cut->propose( input( it_bins      = lt_bins
                                             iv_threshold = 20 ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_lines ).
  ENDMETHOD.

  METHOD zero_capacity.
    DATA lt_bins TYPE zcl_alloc_consolidation=>ty_item_tt.

    APPEND bin( iv_lgort = 'L1' iv_qty = '0' iv_capacity = '0' )
      TO lt_bins.

    DATA(lt_lines) = mo_cut->propose( input( it_bins      = lt_bins
                                             iv_threshold = 20 ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_lines ).
  ENDMETHOD.

ENDCLASS.

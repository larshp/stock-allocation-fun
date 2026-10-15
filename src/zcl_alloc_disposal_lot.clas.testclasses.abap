CLASS ltcl_alloc_disposal_lot DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_disposal_lot.

    METHODS setup.

    METHODS adds_lots      FOR TESTING.
    METHODS ignores_bad    FOR TESTING.
    METHODS totals         FOR TESTING.
    METHODS counts_lots    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_disposal_lot IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_disposal_lot( ).
  ENDMETHOD.

  METHOD adds_lots.
    DATA lt_lots TYPE zcl_alloc_disposal_lot=>ty_lot_tt.

    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = 'L1' iv_quantity = 5 ).
    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = 'L2' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-lot exp = 'L2' ).
  ENDMETHOD.

  METHOD ignores_bad.
    DATA lt_lots TYPE zcl_alloc_disposal_lot=>ty_lot_tt.

    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = 'L1' iv_quantity = 5 ).
    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = '' iv_quantity = 7 ).
    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = 'L3' iv_quantity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 1 ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_lots TYPE zcl_alloc_disposal_lot=>ty_lot_tt.

    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = 'L1' iv_quantity = 5 ).
    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = 'L2' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lots ) exp = 8 ).
  ENDMETHOD.

  METHOD counts_lots.
    DATA lt_lots TYPE zcl_alloc_disposal_lot=>ty_lot_tt.

    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = 'L1' iv_quantity = 5 ).
    lt_lots = mo_cut->add( it_lots = lt_lots iv_lot = 'L2' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lot_count( lt_lots ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.

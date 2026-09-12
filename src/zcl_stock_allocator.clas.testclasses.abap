CLASS lcl_uom_stub DEFINITION
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_uom_converter.

ENDCLASS.


CLASS lcl_uom_stub IMPLEMENTATION.

  METHOD zif_uom_converter~to_base_qty.
    rv_base_qty = iv_qty.
    IF iv_meinh = 'CS'.
      rv_base_qty = iv_qty * 12.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_stock_reader_stub DEFINITION
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    METHODS add_stock
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_labst TYPE menge_d DEFAULT 0
        iv_insme TYPE menge_d DEFAULT 0
        iv_speme TYPE menge_d DEFAULT 0
        iv_einme TYPE menge_d DEFAULT 0
        iv_umlme TYPE menge_d DEFAULT 0
        iv_charg TYPE zif_stock_reader=>ty_stock-charg DEFAULT ''
        iv_vfdat TYPE zif_stock_reader=>ty_stock-expiry_date DEFAULT '00000000'.

  PRIVATE SECTION.
    DATA mt_stock TYPE zif_stock_reader=>ty_stock_tt.

ENDCLASS.


CLASS lcl_stock_reader_stub IMPLEMENTATION.

  METHOD zif_stock_reader~read_stock.
    rt_stock = mt_stock.
  ENDMETHOD.

  METHOD add_stock.
    DATA ls_stock TYPE zif_stock_reader=>ty_stock.

    ls_stock-matnr            = 'MAT-1'.
    ls_stock-werks            = '1000'.
    ls_stock-lgort            = iv_lgort.
    ls_stock-charg            = iv_charg.
    ls_stock-expiry_date      = iv_vfdat.
    ls_stock-unrestricted_qty = iv_labst.
    ls_stock-quality_qty      = iv_insme.
    ls_stock-blocked_qty      = iv_speme.
    ls_stock-restricted_qty   = iv_einme.
    ls_stock-in_transit_qty   = iv_umlme.

    APPEND ls_stock TO mt_stock.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_stock_allocator DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_reader       TYPE REF TO lcl_stock_reader_stub.
    DATA mt_requirements TYPE zif_requirement_reader=>ty_requirement_tt.

    METHODS setup.

    METHODS add_stock
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_labst TYPE menge_d DEFAULT 0
        iv_insme TYPE menge_d DEFAULT 0
        iv_speme TYPE menge_d DEFAULT 0
        iv_charg TYPE zif_stock_reader=>ty_stock-charg DEFAULT ''
        iv_vfdat TYPE zif_stock_reader=>ty_stock-expiry_date DEFAULT '00000000'.

    METHODS cut
      IMPORTING
        is_policy     TYPE zcl_stock_allocator=>ty_policy OPTIONAL
      RETURNING
        VALUE(ro_cut) TYPE REF TO zcl_stock_allocator.

    METHODS run_allocation
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS add_requirement
      IMPORTING
        iv_id       TYPE zif_requirement_reader=>ty_requirement-id
        iv_qty      TYPE menge_d
        iv_priority TYPE i DEFAULT 1
        iv_date     TYPE d OPTIONAL
        iv_unit     TYPE zif_requirement_reader=>ty_requirement-unit DEFAULT ''.

    METHODS fefo_policy
      RETURNING
        VALUE(rs_policy) TYPE zcl_stock_allocator=>ty_policy.

    METHODS whole_units_result
      IMPORTING
        iv_qty           TYPE menge_d
        iv_unit          TYPE zif_requirement_reader=>ty_requirement-unit DEFAULT 'CS'
        iv_whole         TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS priority_order_wins          FOR TESTING.
    METHODS shortage_is_reported         FOR TESTING.
    METHODS splits_across_bins           FOR TESTING.
    METHODS blocked_not_used_by_default  FOR TESTING.
    METHODS quality_used_when_policy_set FOR TESTING.
    METHODS never_over_allocates         FOR TESTING.
    METHODS no_stock_all_shortage        FOR TESTING.
    METHODS equal_priority_uses_date     FOR TESTING.
    METHODS fefo_uses_earliest_batch     FOR TESTING.
    METHODS fefo_unknown_expiry_last     FOR TESTING.
    METHODS default_order_ignores_dates  FOR TESTING.
    METHODS converts_sales_unit_to_base  FOR TESTING.
    METHODS unit_without_converter_kept  FOR TESTING.
    METHODS whole_units_rounds_down      FOR TESTING.
    METHODS whole_units_full_demand      FOR TESTING.
    METHODS whole_units_spans_bins       FOR TESTING.
    METHODS whole_units_off_by_default   FOR TESTING.
    METHODS whole_units_ignored_no_unit  FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_allocator IMPLEMENTATION.

  METHOD setup.
    mo_reader = NEW #( ).
    CLEAR mt_requirements.
  ENDMETHOD.

  METHOD add_stock.
    mo_reader->add_stock( iv_lgort = iv_lgort
                          iv_labst = iv_labst
                          iv_insme = iv_insme
                          iv_speme = iv_speme
                          iv_charg = iv_charg
                          iv_vfdat = iv_vfdat ).
  ENDMETHOD.

  METHOD cut.
    IF is_policy IS SUPPLIED.
      ro_cut = NEW #( io_stock_reader = mo_reader
                      is_policy       = is_policy ).
    ELSE.
      ro_cut = NEW #( io_stock_reader = mo_reader ).
    ENDIF.
  ENDMETHOD.

  METHOD run_allocation.
    rt_result = cut( )->allocate( iv_matnr        = 'MAT-1'
                                  iv_werks        = '1000'
                                  it_requirements = mt_requirements ).
  ENDMETHOD.

  METHOD add_requirement.
    DATA ls_requirement TYPE zif_requirement_reader=>ty_requirement.
    DATA lv_date        TYPE d.

    lv_date = iv_date.
    IF lv_date IS INITIAL.
      lv_date = '20260101'.
    ENDIF.

    ls_requirement-id             = iv_id.
    ls_requirement-priority       = iv_priority.
    ls_requirement-requested_date = lv_date.
    ls_requirement-unit           = iv_unit.
    ls_requirement-requested_qty  = iv_qty.

    APPEND ls_requirement TO mt_requirements.
  ENDMETHOD.

  METHOD fefo_policy.
    rs_policy-use_fefo = abap_true.
  ENDMETHOD.

  METHOD whole_units_result.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    ls_policy-whole_sales_units = iv_whole.

    add_requirement( iv_id   = 'A'
                     iv_qty  = iv_qty
                     iv_unit = iv_unit ).

    DATA(lo_cut) = NEW zcl_stock_allocator(
      io_stock_reader  = mo_reader
      io_uom_converter = NEW lcl_uom_stub( )
      is_policy        = ls_policy ).

    rt_result = lo_cut->allocate( iv_matnr        = 'MAT-1'
                                  iv_werks        = '1000'
                                  it_requirements = mt_requirements ).
  ENDMETHOD.

  METHOD priority_order_wins.
    add_stock( iv_lgort = '0001' iv_labst = '10' ).
    add_requirement( iv_id = 'LOW' iv_qty = '10' iv_priority = 9 ).
    add_requirement( iv_id = 'HIGH' iv_qty = '10' iv_priority = 1 ).

    DATA(lt_result) = run_allocation( ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-requirement_id
                                        exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-requirement_id
                                        exp = 'LOW' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD shortage_is_reported.
    add_stock( iv_lgort = '0001' iv_labst = '4' ).
    add_requirement( iv_id = 'A' iv_qty = '10' ).

    DATA(lt_result) = run_allocation( ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-requested_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '6' ).
  ENDMETHOD.

  METHOD splits_across_bins.
    add_stock( iv_lgort = '0001' iv_labst = '3' ).
    add_stock( iv_lgort = '0002' iv_labst = '5' ).
    add_requirement( iv_id = 'A' iv_qty = '6' ).

    DATA(lt_result) = run_allocation( ).
    DATA(lt_allocations) = lt_result[ 1 ]-allocations.

    cl_abap_unit_assert=>assert_equals( act = lines( lt_allocations )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_allocations[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_allocations[ 1 ]-quantity
                                        exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_allocations[ 2 ]-lgort
                                        exp = '0002' ).
    cl_abap_unit_assert=>assert_equals( act = lt_allocations[ 2 ]-quantity
                                        exp = '3' ).
  ENDMETHOD.

  METHOD blocked_not_used_by_default.
    add_stock( iv_lgort = '0001' iv_labst = '2' iv_speme = '100' ).
    add_requirement( iv_id = 'A' iv_qty = '10' ).

    DATA(lt_result) = run_allocation( ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '8' ).
  ENDMETHOD.

  METHOD quality_used_when_policy_set.
    add_stock( iv_lgort = '0001' iv_labst = '2' iv_insme = '5' ).
    add_requirement( iv_id = 'A' iv_qty = '6' ).

    DATA(ls_policy) = VALUE zcl_stock_allocator=>ty_policy(
      include_quality = abap_true ).

    DATA(lt_result) = cut( ls_policy )->allocate(
      iv_matnr        = 'MAT-1'
      iv_werks        = '1000'
      it_requirements = mt_requirements ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '6' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD never_over_allocates.
    add_stock( iv_lgort = '0001' iv_labst = '5' ).
    add_requirement( iv_id = 'A' iv_qty = '4' ).
    add_requirement( iv_id = 'B' iv_qty = '4' ).
    add_requirement( iv_id = 'C' iv_qty = '4' ).

    DATA(lt_result) = run_allocation( ).
    DATA lv_total TYPE menge_d.

    LOOP AT lt_result INTO DATA(ls_result).
      lv_total = lv_total + ls_result-allocated_qty.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = lv_total
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 3 ]-shortage_qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD no_stock_all_shortage.
    add_requirement( iv_id = 'A' iv_qty = '7' ).

    DATA(lt_result) = run_allocation( ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '7' ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_result[ 1 ]-allocations ).
  ENDMETHOD.

  METHOD equal_priority_uses_date.
    add_stock( iv_lgort = '0001' iv_labst = '1' ).
    add_requirement( iv_id = 'LATER' iv_qty = '1' iv_date = '20260301' ).
    add_requirement( iv_id = 'EARLIER' iv_qty = '1' iv_date = '20260101' ).

    DATA(lt_result) = run_allocation( ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-requirement_id
                                        exp = 'EARLIER' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD fefo_uses_earliest_batch.
    add_stock( iv_lgort = '0001' iv_labst = '3' iv_charg = 'OLD'
               iv_vfdat = '20260101' ).
    add_stock( iv_lgort = '0001' iv_labst = '3' iv_charg = 'NEW'
               iv_vfdat = '20261231' ).
    add_requirement( iv_id = 'A' iv_qty = '4' ).

    DATA(lt_result) = cut( fefo_policy( ) )->allocate(
      iv_matnr        = 'MAT-1'
      iv_werks        = '1000'
      it_requirements = mt_requirements ).
    DATA(lt_allocations) = lt_result[ 1 ]-allocations.

    cl_abap_unit_assert=>assert_equals( act = lt_allocations[ 1 ]-charg
                                        exp = 'OLD' ).
    cl_abap_unit_assert=>assert_equals( act = lt_allocations[ 1 ]-quantity
                                        exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_allocations[ 2 ]-charg
                                        exp = 'NEW' ).
    cl_abap_unit_assert=>assert_equals( act = lt_allocations[ 2 ]-quantity
                                        exp = '1' ).
  ENDMETHOD.

  METHOD fefo_unknown_expiry_last.
    add_stock( iv_lgort = '0001' iv_labst = '2' iv_charg = 'UNKNOWN' ).
    add_stock( iv_lgort = '0001' iv_labst = '2' iv_charg = 'DATED'
               iv_vfdat = '20261231' ).
    add_requirement( iv_id = 'A' iv_qty = '2' ).

    DATA(lt_result) = cut( fefo_policy( ) )->allocate(
      iv_matnr        = 'MAT-1'
      iv_werks        = '1000'
      it_requirements = mt_requirements ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocations[ 1 ]-charg exp = 'DATED' ).
  ENDMETHOD.

  METHOD default_order_ignores_dates.
    add_stock( iv_lgort = '0001' iv_labst = '5' iv_charg = 'LATE'
               iv_vfdat = '20261231' ).
    add_stock( iv_lgort = '0001' iv_labst = '5' iv_charg = 'EARLY'
               iv_vfdat = '20260101' ).
    add_requirement( iv_id = 'A' iv_qty = '2' ).

    DATA(lt_result) = run_allocation( ).

    " without the FEFO policy the reader order is kept
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocations[ 1 ]-charg exp = 'LATE' ).
  ENDMETHOD.

  METHOD converts_sales_unit_to_base.
    add_stock( iv_lgort = '0001' iv_labst = '10' ).
    add_requirement( iv_id = 'A' iv_qty = '2' iv_unit = 'CS' ).

    DATA(lo_cut) = NEW zcl_stock_allocator(
      io_stock_reader  = mo_reader
      io_uom_converter = NEW lcl_uom_stub( ) ).

    DATA(lt_result) = lo_cut->allocate( iv_matnr        = 'MAT-1'
                                        iv_werks        = '1000'
                                        it_requirements = mt_requirements ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-requested_qty
                                        exp = '24' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '14' ).
  ENDMETHOD.

  METHOD unit_without_converter_kept.
    add_stock( iv_lgort = '0001' iv_labst = '10' ).
    add_requirement( iv_id = 'A' iv_qty = '5' iv_unit = 'CS' ).

    DATA(lt_result) = run_allocation( ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-requested_qty
                                        exp = '5' ).
  ENDMETHOD.

  METHOD whole_units_rounds_down.
    add_stock( iv_lgort = '0001' iv_labst = '30' ).

    DATA(lt_result) = whole_units_result( iv_qty = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-requested_qty
                                        exp = '48' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '24' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '24' ).
  ENDMETHOD.

  METHOD whole_units_full_demand.
    add_stock( iv_lgort = '0001' iv_labst = '100' ).

    DATA(lt_result) = whole_units_result( iv_qty = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '48' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD whole_units_spans_bins.
    add_stock( iv_lgort = '0001' iv_labst = '24' ).
    add_stock( iv_lgort = '0002' iv_labst = '24' ).

    DATA(lt_result) = whole_units_result( iv_qty = '3' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '36' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result[ 1 ]-allocations ) exp = 2 ).
  ENDMETHOD.

  METHOD whole_units_off_by_default.
    add_stock( iv_lgort = '0001' iv_labst = '30' ).

    DATA(lt_result) = whole_units_result( iv_qty   = '4'
                                          iv_whole = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '30' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '18' ).
  ENDMETHOD.

  METHOD whole_units_ignored_no_unit.
    add_stock( iv_lgort = '0001' iv_labst = '30' ).

    DATA(lt_result) = whole_units_result( iv_qty  = '30'
                                          iv_unit = '' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '30' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

ENDCLASS.

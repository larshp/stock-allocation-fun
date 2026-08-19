CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_matnr TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mt_matnr TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_matnr = it_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    " the mass run never reads demand itself, the service does
    CLEAR rt_demand.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_service_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_service.

    METHODS constructor
      IMPORTING
        iv_fails_for TYPE mard-matnr OPTIONAL.

    METHODS get_seen
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mv_fails_for TYPE mard-matnr.
    DATA mt_seen      TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_service_double IMPLEMENTATION.

  METHOD constructor.
    mv_fails_for = iv_fails_for.
  ENDMETHOD.

  METHOD zif_allocation_service~simulate.
    rs_run = zif_allocation_service~run(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    CLEAR rs_run-run_id.
    CLEAR rs_run-reservation.
  ENDMETHOD.

  METHOD zif_allocation_service~run.

    APPEND iv_matnr TO mt_seen.

    IF iv_matnr = mv_fails_for.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>reserve_failed
        mv_message = `stock is blocked` ).
    ENDIF.

    rs_run = VALUE #(
      run_id     = |RUN-{ iv_matnr }|
      allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '10' shortfall = 0 ) ) ).

  ENDMETHOD.

  METHOD get_seen.
    rt_matnr = mt_seen.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_mass_run DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_service TYPE REF TO lcl_service_double.

    METHODS mass_run_over
      IMPORTING
        it_matnr          TYPE zif_demand_reader=>ty_matnr_tab
        iv_fails_for      TYPE mard-matnr OPTIONAL
        iv_simulate       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_outcome) TYPE zcl_allocation_mass_run=>ty_outcome_tab.

    METHODS every_material_is_allocated FOR TESTING.
    METHODS nothing_waiting_does_nothing FOR TESTING.
    METHODS one_failure_does_not_stop_run FOR TESTING.
    METHODS failure_carries_the_reason FOR TESTING.
    METHODS simulation_changes_nothing FOR TESTING.

ENDCLASS.


CLASS ltcl_mass_run IMPLEMENTATION.

  METHOD mass_run_over.

    DATA lo_demand TYPE REF TO zif_demand_reader.

    mo_service = NEW #( iv_fails_for ).
    lo_demand  = NEW lcl_demand_double( it_matnr ).

    rt_outcome = NEW zcl_allocation_mass_run(
      io_service = mo_service
      io_demand  = lo_demand )->run(
        iv_werks    = c_werks
        iv_simulate = iv_simulate ).

  ENDMETHOD.

  METHOD every_material_is_allocated.

    DATA(lt_outcome) = mass_run_over( VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_service->get_seen( )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 2 ]-run-run_id
      exp = 'RUN-MAT-2' ).

  ENDMETHOD.

  METHOD nothing_waiting_does_nothing.

    cl_abap_unit_assert=>assert_initial( mass_run_over( VALUE #( ) ) ).

  ENDMETHOD.

  METHOD one_failure_does_not_stop_run.

    DATA(lt_outcome) = mass_run_over(
      it_matnr     = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) )
      iv_fails_for = 'MAT-2' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = 3
      msg = 'a blocked material must not cost the rest of the run' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 3 ]-run-run_id
      exp = 'RUN-MAT-3'
      msg = 'the materials after the failure must still be allocated' ).

  ENDMETHOD.

  METHOD simulation_changes_nothing.

    DATA(lt_outcome) = mass_run_over(
      it_matnr    = VALUE #( ( 'MAT-1' ) )
      iv_simulate = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_outcome )
      exp = 1 ).
    cl_abap_unit_assert=>assert_not_initial(
      act = lt_outcome[ 1 ]-run-allocation
      msg = 'a simulation must still say who would get what' ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_outcome[ 1 ]-run-run_id
      msg = 'a simulation has no run to look up, because nothing was recorded' ).

  ENDMETHOD.

  METHOD failure_carries_the_reason.

    DATA(lt_outcome) = mass_run_over(
      it_matnr     = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) )
      iv_fails_for = 'MAT-2' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 1 ]-failed
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_outcome[ 2 ]-failed
      exp = abap_true ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_outcome[ 2 ]-reason
      exp = '*stock is blocked*'
      msg = 'the log must say why a material was skipped' ).
    cl_abap_unit_assert=>assert_initial( lt_outcome[ 2 ]-run ).

  ENDMETHOD.

ENDCLASS.

CLASS lcl_service_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_service.

    METHODS constructor
      IMPORTING
        is_run       TYPE zif_allocation_service=>ty_run OPTIONAL
        iv_fails_for TYPE mard-matnr OPTIONAL.

  PRIVATE SECTION.
    DATA ms_run       TYPE zif_allocation_service=>ty_run.
    DATA mv_fails_for TYPE mard-matnr.

ENDCLASS.


CLASS lcl_service_double IMPLEMENTATION.

  METHOD constructor.
    ms_run       = is_run.
    mv_fails_for = iv_fails_for.
  ENDMETHOD.

  METHOD zif_allocation_service~run.
    IF iv_matnr = mv_fails_for.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>reserve_failed
        mv_message = `stock is blocked` ).
    ENDIF.
    rs_run = ms_run.
  ENDMETHOD.

ENDCLASS.


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
    " the report never reads demand itself, the service does
    CLEAR rt_demand.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_allocation_report DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'REPORT-TEST-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS report_of
      IMPORTING
        is_run         TYPE zif_allocation_service=>ty_run
        it_matnr       TYPE zif_demand_reader=>ty_matnr_tab
        iv_fails_for   TYPE mard-matnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE zcl_allocation_report=>ty_line_tab.

    METHODS one_material_run FOR TESTING.
    METHODS heading_names_the_run FOR TESTING.
    METHODS one_line_per_demand FOR TESTING.
    METHODS quantities_are_totalled FOR TESTING.
    METHODS columns_line_up FOR TESTING.
    METHODS every_material_gets_a_block FOR TESTING.
    METHODS rejected_material_shows_reason FOR TESTING.
    METHODS footer_counts_the_failures FOR TESTING.

ENDCLASS.


CLASS ltcl_allocation_report IMPLEMENTATION.

  METHOD report_of.

    DATA lo_service TYPE REF TO zif_allocation_service.
    DATA lo_demand  TYPE REF TO zif_demand_reader.

    lo_service = NEW lcl_service_double(
      is_run       = is_run
      iv_fails_for = iv_fails_for ).
    lo_demand  = NEW lcl_demand_double( it_matnr ).

    rt_line = NEW zcl_allocation_report(
      NEW zcl_allocation_mass_run(
        io_service = lo_service
        io_demand  = lo_demand ) )->run( c_werks ).

  ENDMETHOD.

  METHOD one_material_run.

    DATA(lt_line) = report_of(
      is_run   = VALUE #( run_id = 'RUN-0001' )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 1 ]
      exp = |*{ c_werks }*| ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = |*{ c_matnr }*| ).

  ENDMETHOD.

  METHOD heading_names_the_run.

    DATA(lt_line) = report_of(
      is_run   = VALUE #( run_id = 'RUN-0001' reservation = '0000004711' )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = '*RUN-0001*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 5 ]
      exp = '*0000004711*' ).

  ENDMETHOD.

  METHOD one_line_per_demand.

    DATA(lt_line) = report_of(
      is_run   = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' )
          ( demand_id = 'D2' requested = '5'  confirmed = '5' shortfall = 0 ) ) )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = 'D1*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 8 ]
      exp = 'D2*' ).

  ENDMETHOD.

  METHOD quantities_are_totalled.

    DATA(lt_line) = report_of(
      is_run   = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = 'D1' requested = '10'  confirmed = '4'   shortfall = '6' )
          ( demand_id = 'D2' requested = '5.5' confirmed = '5.5' shortfall = 0 ) ) )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 9 ]
      exp = 'Total*15.500*9.500*6.000*' ).

  ENDMETHOD.

  METHOD columns_line_up.

    DATA(lt_line) = report_of(
      is_run   = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = '0000004711000010' requested = '1000' confirmed = '1' shortfall = '999' ) ) )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = strlen( lt_line[ 6 ] )
      exp = strlen( lt_line[ 7 ] )
      msg = 'the column heading and the rows must be the same width' ).

  ENDMETHOD.

  METHOD every_material_gets_a_block.

    DATA(lt_line) = report_of(
      is_run   = VALUE #( run_id = 'RUN-0001' )
      it_matnr = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*MAT-1*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 9 ]
      exp = '*MAT-2*' ).

  ENDMETHOD.

  METHOD rejected_material_shows_reason.

    DATA(lt_line) = report_of(
      is_run       = VALUE #( run_id = 'RUN-0001' )
      it_matnr     = VALUE #( ( 'MAT-1' ) )
      iv_fails_for = 'MAT-1' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = 'Allocation failed:*stock is blocked*'
      msg = 'the user must be told why a material got nothing' ).

  ENDMETHOD.

  METHOD footer_counts_the_failures.

    DATA(lt_line) = report_of(
      is_run       = VALUE #( run_id = 'RUN-0001' )
      it_matnr     = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) )
      iv_fails_for = 'MAT-2' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_line[ lines( lt_line ) ]
      exp = `3 materials, 1 failed` ).

  ENDMETHOD.

ENDCLASS.

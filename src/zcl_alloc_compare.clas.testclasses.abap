"! Answers with a fixed timeline.
CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    METHODS constructor
      IMPORTING
        iv_available TYPE zif_allocation=>ty_quantity.

  PRIVATE SECTION.
    DATA mv_available TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mv_available = iv_available.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.
    rt_supply = VALUE #( ( avail_date = '00000000' quantity = mv_available ) ).
  ENDMETHOD.

ENDCLASS.


"! Answers with a fixed demand.
CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab.

  PRIVATE SECTION.
    DATA mt_demand TYPE zif_allocation=>ty_demand_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_demand = it_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = mt_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    CLEAR rt_matnr.
  ENDMETHOD.

ENDCLASS.


"! Allows every plant, and remembers which one it was asked about.
CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS get_plant
      RETURNING
        VALUE(rv_werks) TYPE mard-werks.

  PRIVATE SECTION.
    DATA mv_werks TYPE mard-werks.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD get_plant.
    rv_werks = mv_werks.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.
    mv_werks = iv_werks.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_compare DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'COMPARE-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_authority TYPE REF TO lcl_authority_double.

    METHODS setup.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_priority      TYPE zif_allocation=>ty_priority
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS compared_with
      IMPORTING
        is_settings    TYPE zif_alloc_config=>ty_config
        iv_available   TYPE zif_allocation=>ty_quantity
        it_demand      TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_compare=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS compared
      IMPORTING
        iv_available   TYPE zif_allocation=>ty_quantity
        it_demand      TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_compare=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS both_rules_are_shown FOR TESTING RAISING cx_static_check.
    METHODS priority_serves_the_first FOR TESTING RAISING cx_static_check.
    METHODS fair_share_splits_it FOR TESTING RAISING cx_static_check.
    METHODS the_totals_are_the_same FOR TESTING RAISING cx_static_check.
    METHODS whole_lines_are_counted FOR TESTING RAISING cx_static_check.
    METHODS nothing_waiting_says_so FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.
    METHODS the_plants_bar_is_kept FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_compare IMPLEMENTATION.

  METHOD setup.
    mo_authority = NEW lcl_authority_double( ).
  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = '20260301'
      priority  = iv_priority ).

  ENDMETHOD.

  METHOD compared.

    rt_line = compared_with(
      is_settings  = VALUE #( )
      iv_available = iv_available
      it_demand    = it_demand ).

  ENDMETHOD.

  METHOD compared_with.

    DATA(lo_cut) = NEW zcl_alloc_compare(
      io_supply    = NEW lcl_supply_double( iv_available )
      io_demand    = NEW lcl_demand_double( it_demand )
      io_authority = mo_authority
      is_settings  = is_settings ).

    rt_line = lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD both_rules_are_shown.

    DATA(lt_line) = compared(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*By priority*Fair share*'
      msg = 'the two answers belong next to each other or they cannot be compared' ).

  ENDMETHOD.

  METHOD priority_serves_the_first.

    DATA(lt_line) = compared(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = '10'
                  iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*D1*10.000*10.000*5.000*'
      msg = 'priority gives the urgent line everything, fair share gives it half' ).

  ENDMETHOD.

  METHOD fair_share_splits_it.

    DATA(lt_line) = compared(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = '10'
                  iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = '*D2*10.000*0.000*5.000*'
      msg = 'and the line priority left with nothing gets half the other way' ).

  ENDMETHOD.

  METHOD the_totals_are_the_same.

    DATA(lt_line) = compared(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = '10'
                  iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 5 ]
      exp = '*Total*10.000*10.000*'
      msg = 'both rules hand out the same stock, which is not what the choice is about' ).

  ENDMETHOD.

  METHOD whole_lines_are_counted.

    DATA(lt_line) = compared(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = '10'
                  iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ lines( lt_line ) ]
      exp = 'Lines served in full: 1 by priority, 0 by fair share'
      msg = 'who ends up with something they can ship is what the choice is about' ).

  ENDMETHOD.

  METHOD nothing_waiting_says_so.

    DATA(lt_line) = compared(
      iv_available = '10'
      it_demand    = VALUE #( ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*Nothing is waiting*' ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    compared(
      iv_available = '10'
      it_demand    = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->get_plant( )
      exp = c_werks ).

  ENDMETHOD.

  METHOD the_plants_bar_is_kept.

    " the report compares the distribution rule and nothing else: a plant that
    " will not ship less than half a line ships less than half a line under
    " neither of them, and a comparison that forgets the rest of the settings
    " compares two runs the plant would never make
    DATA(lt_line) = compared_with(
      is_settings  = VALUE #( min_percent = 50 )
      iv_available = '4'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*D1*10.000*0.000*0.000*' ).

  ENDMETHOD.

ENDCLASS.

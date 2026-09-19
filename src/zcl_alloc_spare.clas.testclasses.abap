"! Hands out what it was told, per plant.
CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    TYPES:
      BEGIN OF ty_row,
        matnr      TYPE mard-matnr,
        werks      TYPE mard-werks,
        avail_date TYPE d,
        quantity   TYPE zif_allocation=>ty_quantity,
      END OF ty_row.
    TYPES ty_row_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_row TYPE ty_row_tab.

  PRIVATE SECTION.
    DATA mt_row TYPE ty_row_tab.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mt_row = it_row.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    LOOP AT mt_row INTO DATA(ls_row)
        WHERE matnr = iv_matnr
          AND werks = iv_werks.
      APPEND VALUE #(
        avail_date = ls_row-avail_date
        quantity   = ls_row-quantity ) TO rt_supply.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.


"! Hands out the demand it was told, per plant.
CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_row TYPE lcl_supply_double=>ty_row_tab.

  PRIVATE SECTION.
    DATA mt_row TYPE lcl_supply_double=>ty_row_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_row = it_row.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    LOOP AT mt_row INTO DATA(ls_row)
        WHERE matnr = iv_matnr
          AND werks = iv_werks.
      APPEND VALUE #(
        demand_id = |{ ls_row-werks }|
        matnr     = ls_row-matnr
        werks     = ls_row-werks
        quantity  = ls_row-quantity ) TO rt_demand.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    CLEAR rt_matnr.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_spare DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'SPARE-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'SPARE-02'.
    CONSTANTS c_werks TYPE mard-werks VALUE '2000'.
    CONSTANTS c_away  TYPE mard-werks VALUE '3000'.

    METHODS spare_of
      IMPORTING
        it_supply       TYPE lcl_supply_double=>ty_row_tab
        it_demand       TYPE lcl_supply_double=>ty_row_tab OPTIONAL
        iv_matnr        TYPE mard-matnr DEFAULT c_matnr
        iv_werks        TYPE mard-werks DEFAULT c_werks
      RETURNING
        VALUE(rs_spare) TYPE zcl_alloc_spare=>ty_spare
      RAISING
        zcx_allocation.

    METHODS an_empty_plant_spares_nothing FOR TESTING RAISING cx_static_check.
    METHODS the_shelf_is_spare FOR TESTING RAISING cx_static_check.
    METHODS coming_stock_is_its_own_number FOR TESTING RAISING cx_static_check.
    METHODS what_is_wanted_comes_off FOR TESTING RAISING cx_static_check.
    METHODS a_plant_that_owes_it_all FOR TESTING RAISING cx_static_check.
    METHODS owing_more_than_it_has FOR TESTING RAISING cx_static_check.
    METHODS another_plant_is_not_asked FOR TESTING RAISING cx_static_check.
    METHODS another_material_is_not_asked FOR TESTING RAISING cx_static_check.
    METHODS a_negative_demand_line_is_out FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_spare IMPLEMENTATION.

  METHOD spare_of.

    DATA(lo_cut) = NEW zcl_alloc_spare(
      io_supply = NEW lcl_supply_double( it_supply )
      io_demand = NEW lcl_demand_double( it_demand ) ).

    rs_spare = lo_cut->at_plant(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD an_empty_plant_spares_nothing.

    DATA(ls_spare) = spare_of( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-spare
      exp = 0 ).

  ENDMETHOD.

  METHOD the_shelf_is_spare.

    DATA(ls_spare) = spare_of(
      VALUE #( ( matnr = c_matnr werks = c_werks quantity = '25' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-on_hand
      exp = '25' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-spare
      exp = '25' ).

  ENDMETHOD.

  METHOD coming_stock_is_its_own_number.

    " stock that is not there yet could still be transferred, and is not the
    " same offer as stock on the shelf -- so it counts towards the spare and
    " is still reported apart from it
    DATA(ls_spare) = spare_of( VALUE #(
      ( matnr = c_matnr werks = c_werks quantity = '10' )
      ( matnr = c_matnr werks = c_werks avail_date = '20260401' quantity = '15' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-on_hand
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-coming
      exp = '15' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-spare
      exp = '25' ).

  ENDMETHOD.

  METHOD what_is_wanted_comes_off.

    DATA(ls_spare) = spare_of(
      it_supply = VALUE #( ( matnr = c_matnr werks = c_werks quantity = '60' ) )
      it_demand = VALUE #( ( matnr = c_matnr werks = c_werks quantity = '50' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-wanted
      exp = '50' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-spare
      exp = '10' ).

  ENDMETHOD.

  METHOD a_plant_that_owes_it_all.

    " a hundred on the shelf and a hundred waiting for them is nothing to send
    DATA(ls_spare) = spare_of(
      it_supply = VALUE #( ( matnr = c_matnr werks = c_werks quantity = '100' ) )
      it_demand = VALUE #( ( matnr = c_matnr werks = c_werks quantity = '100' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-spare
      exp = 0 ).

  ENDMETHOD.

  METHOD owing_more_than_it_has.

    " what that plant is short of itself is its own problem, and a negative
    " spare would read as a quantity somebody could ask for
    DATA(ls_spare) = spare_of(
      it_supply = VALUE #( ( matnr = c_matnr werks = c_werks quantity = '10' ) )
      it_demand = VALUE #( ( matnr = c_matnr werks = c_werks quantity = '50' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-spare
      exp = 0 ).

  ENDMETHOD.

  METHOD another_plant_is_not_asked.

    DATA(ls_spare) = spare_of(
      VALUE #( ( matnr = c_matnr werks = c_away quantity = '99' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-on_hand
      exp = 0 ).

  ENDMETHOD.

  METHOD another_material_is_not_asked.

    DATA(ls_spare) = spare_of(
      VALUE #( ( matnr = c_other werks = c_werks quantity = '99' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-on_hand
      exp = 0 ).

  ENDMETHOD.

  METHOD a_negative_demand_line_is_out.

    " a returns line is not a plant owing stock, and adding it in would make
    " the plant look as though it had more to give away than it has
    DATA(ls_spare) = spare_of(
      it_supply = VALUE #( ( matnr = c_matnr werks = c_werks quantity = '30' ) )
      it_demand = VALUE #(
        ( matnr = c_matnr werks = c_werks quantity = '10' )
        ( matnr = c_matnr werks = c_werks quantity = '-5' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-wanted
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_spare-spare
      exp = '20' ).

  ENDMETHOD.

ENDCLASS.

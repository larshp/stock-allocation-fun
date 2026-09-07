CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    METHODS constructor
      IMPORTING
        it_supply TYPE zif_supply_reader=>ty_supply_tab.

  PRIVATE SECTION.
    DATA mt_supply TYPE zif_supply_reader=>ty_supply_tab.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mt_supply = it_supply.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.
    rt_supply = mt_supply.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_supply_extra DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'EXTRA-MAT-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'EXTRA-MAT-02'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9601'.

    METHODS cut
      IMPORTING
        iv_quantity   TYPE zif_allocation=>ty_quantity DEFAULT 50
        iv_date       TYPE d OPTIONAL
      RETURNING
        VALUE(ro_cut) TYPE REF TO zif_supply_reader.

    METHODS the_extra_is_added FOR TESTING RAISING cx_static_check.
    METHODS it_carries_its_day FOR TESTING RAISING cx_static_check.
    METHODS another_material_is_untouched FOR TESTING RAISING cx_static_check.
    METHODS nothing_extra_is_nothing FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_supply_extra IMPLEMENTATION.

  METHOD cut.

    ro_cut = NEW zcl_supply_extra(
      io_supply   = NEW lcl_supply_double( VALUE #( ( quantity = 10 ) ) )
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = iv_quantity
      iv_date     = iv_date ).

  ENDMETHOD.

  METHOD the_extra_is_added.

    DATA(lt_supply) = cut( )->read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_supply )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_supply[ 2 ]-quantity
      exp = CONV zif_allocation=>ty_quantity( 50 ) ).

  ENDMETHOD.

  METHOD it_carries_its_day.

    DATA(lt_supply) = cut( iv_date = '20260710' )->read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_supply[ 2 ]-avail_date
      exp = CONV d( '20260710' )
      msg = 'a delivery on Friday cannot serve a line that ships on Thursday' ).

  ENDMETHOD.

  METHOD another_material_is_untouched.

    DATA(lt_supply) = cut( )->read_supply(
      iv_matnr = c_other
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_supply )
      exp = 1
      msg = 'a run over the rest of the plant must not find imaginary stock' ).

  ENDMETHOD.

  METHOD nothing_extra_is_nothing.

    DATA(lt_supply) = cut( iv_quantity = 0 )->read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_supply )
      exp = 1 ).

  ENDMETHOD.

ENDCLASS.

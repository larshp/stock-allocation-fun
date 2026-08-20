CLASS zcl_alloc_extensions DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_class_tab TYPE STANDARD TABLE OF zstock_alloc_ext-classname WITH EMPTY KEY.

    "! `ZSTOCK_ALLOC_EXT-KIND`: what the class is a source of.
    CONSTANTS c_supply TYPE zstock_alloc_ext-kind VALUE 'S'.
    CONSTANTS c_demand TYPE zstock_alloc_ext-kind VALUE 'D'.

    "! <p class="shorttext synchronized">Classes a customer has added as a source</p>
    "!
    "! Everything a plant is likely to want to change sits behind an interface,
    "! and until now using that meant writing a factory method of your own and
    "! keeping it in step with this one through every upgrade.
    "! `ZSTOCK_ALLOC_EXT` is the same seam without the copy: name a class that
    "! implements the interface and it joins the sources the run reads. A row
    "! without a plant applies to every plant.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_kind  | <p class="shorttext synchronized">Supply or demand</p>
    "! @parameter rt_class | <p class="shorttext synchronized">Class names, in a settled order</p>
    CLASS-METHODS classes_of
      IMPORTING
        iv_werks        TYPE mard-werks
        iv_kind         TYPE zstock_alloc_ext-kind
      RETURNING
        VALUE(rt_class) TYPE ty_class_tab.

    "! <p class="shorttext synchronized">Create one of the configured classes</p>
    "!
    "! @parameter iv_class       | <p class="shorttext synchronized">Class name from the table</p>
    "! @parameter ro_object      | <p class="shorttext synchronized">A new instance of it</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Class missing, private or the wrong kind</p>
    CLASS-METHODS make
      IMPORTING
        iv_class         TYPE zstock_alloc_ext-classname
      RETURNING
        VALUE(ro_object) TYPE REF TO object
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_alloc_extensions IMPLEMENTATION.

  METHOD make.

    DATA lo_object TYPE REF TO object.

    " a class named in Customizing is a class somebody typed, so everything
    " that can be wrong with it has to come back as an answer rather than as a
    " dump: missing, not public, no parameterless constructor, or simply not a
    " reader of the kind it was configured as
    TRY.
        CREATE OBJECT lo_object TYPE (iv_class).
      CATCH cx_sy_create_object_error.
        RAISE EXCEPTION NEW zcx_allocation(
          textid     = zcx_allocation=>no_source
          mv_message = |{ iv_class }| ).
    ENDTRY.

    IF lo_object IS NOT BOUND.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>no_source
        mv_message = |{ iv_class }| ).
    ENDIF.

    ro_object = lo_object.

  ENDMETHOD.

  METHOD classes_of.

    " the plant's own rows and the ones that apply everywhere, the same shape
    " as the customer priorities in feature 51
    SELECT classname
      FROM zstock_alloc_ext
      WHERE kind = @iv_kind
        AND ( werks = @iv_werks
           OR werks = @space )
      ORDER BY classname
      INTO TABLE @rt_class.
    IF sy-subrc <> 0.
      CLEAR rt_class.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

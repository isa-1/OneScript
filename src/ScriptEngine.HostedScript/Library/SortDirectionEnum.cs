﻿using ScriptEngine.Machine;
using ScriptEngine.Machine.Contexts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ScriptEngine.HostedScript.Library
{
    [SystemEnum("НаправлениеСортировки", "SortDirection")]
    public class SortDirectionEnum : EnumerationContext
    {
        const string ASC = "Возр";
        const string DESC = "Убыв";

        public SortDirectionEnum(TypeDescriptor typeRepresentation, TypeDescriptor valuesType)
            : base(typeRepresentation, valuesType)
        {

        }

        [EnumValue(ASC, "Asc")]
        public EnumerationValue Asc
        {
            get
            {
                return this[ASC];
            }
        }

        [EnumValue(DESC, "Desc")]
        public EnumerationValue Desc
        {
            get
            {
                return this[DESC];
            }
        }

        public static SortDirectionEnum CreateInstance()
        {
            SortDirectionEnum instance;

            TypeDescriptor enumType;
            TypeDescriptor enumValType;

            EnumContextHelper.RegisterEnumType<SortDirectionEnum>(out enumType, out enumValType);

            instance = new SortDirectionEnum(enumType, enumValType);

            EnumContextHelper.RegisterValues<SortDirectionEnum>(instance);

            return instance;
        }
    }
}

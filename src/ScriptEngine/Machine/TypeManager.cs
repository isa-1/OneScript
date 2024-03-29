﻿/*----------------------------------------------------------
This Source Code Form is subject to the terms of the 
Mozilla Public License, v.2.0. If a copy of the MPL 
was not distributed with this file, You can obtain one 
at http://mozilla.org/MPL/2.0/.
----------------------------------------------------------*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ScriptEngine.Machine.Contexts;

namespace ScriptEngine.Machine
{
    interface ITypeManager
    {
        Type GetImplementingClass(int typeId);
        TypeDescriptor GetTypeByName(string name);
        TypeDescriptor GetTypeById(int id);
        TypeDescriptor GetTypeByFrameworkType(Type type);
        TypeDescriptor RegisterType(string name, Type implementingClass);
        TypeDescriptor GetTypeDescriptorFor(IValue typeTypeValue);
        void RegisterAliasFor(TypeDescriptor td, string alias);
        bool IsKnownType(Type type);
        bool IsKnownType(string typeName);
        Type NewInstanceHandler { get; set; }
    }

    class StandartTypeManager : ITypeManager
    {
        private Dictionary<string, int> _knownTypesIndexes = new Dictionary<string, int>(StringComparer.InvariantCultureIgnoreCase);
        private List<KnownType> _knownTypes = new List<KnownType>();
        private Type _dynamicFactory;

        private struct KnownType
        {
            public Type SystemType;
            public TypeDescriptor Descriptor;
        }

        public StandartTypeManager()
        {
            foreach (var item in Enum.GetValues(typeof(DataType)))
            {
                DataType typeEnum = (DataType)item;
                string alias;
                switch (typeEnum)
                {
                    case DataType.Undefined:
                        alias = "Неопределено";
                        break;
                    case DataType.Boolean:
                        alias = "Булево";
                        break;
                    case DataType.String:
                        alias = "Строка";
                        break;
                    case DataType.Date:
                        alias = "Дата";
                        break;
                    case DataType.Number:
                        alias = "Число";
                        break;
                    case DataType.Type:
                        alias = "Тип";
                        break;
                    case DataType.Object:
                        alias = "Object";
                        break;
                    default:
                        continue;
                }

                var td = new TypeDescriptor()
                {
                    Name = alias,
                    ID = (int)typeEnum
                };

                RegisterType(td, typeof(DataType));

            }

            RegisterType("Null", typeof(NullValueImpl));
        }

        #region ITypeManager Members

        public Type GetImplementingClass(int typeId)
        {
            var kt = _knownTypes.First(x => x.Descriptor.ID == typeId);
            return kt.SystemType;
        }

        public TypeDescriptor GetTypeByName(string name)
        {
            int ktIndex;
            try
            {
                ktIndex = _knownTypesIndexes[name];
            }
            catch (KeyNotFoundException)
            {
                throw new RuntimeException(String.Format("Тип не зарегистрирован ({0})", name));
            }

            return _knownTypes[ktIndex].Descriptor;
        }

        public TypeDescriptor GetTypeById(int id)
        {
            return _knownTypes[id].Descriptor;
        }

        public TypeDescriptor RegisterType(string name, Type implementingClass)
        {
            if (_knownTypesIndexes.ContainsKey(name))
            {
                var td = GetTypeByName(name);
                if (GetImplementingClass(td.ID) != implementingClass)
                    throw new InvalidOperationException("Name already registered");

                return td;
            }
            else
            {
                var nextId = _knownTypes.Count;
                var typeDesc = new TypeDescriptor()
                {
                    ID = nextId,
                    Name = name
                };

                RegisterType(typeDesc, implementingClass);
                return typeDesc;
            }

        }

        private void RegisterType(TypeDescriptor td, Type implementingClass)
        {
            _knownTypesIndexes.Add(td.Name, td.ID);
            _knownTypes.Add(new KnownType()
                {
                    Descriptor = td,
                    SystemType = implementingClass
                });
        }

        public void RegisterAliasFor(TypeDescriptor td, string alias)
        {
            _knownTypesIndexes[alias] = td.ID;
        }

        public TypeDescriptor GetTypeByFrameworkType(Type type)
        {
            var kt = _knownTypes.First(x => x.SystemType == type);
            return kt.Descriptor;
        }

        public bool IsKnownType(Type type)
        {
            return _knownTypes.Any(x => x.SystemType == type);
        }

        public bool IsKnownType(string typeName)
        {
            var nameToUpper = typeName.ToUpperInvariant();
            return _knownTypes.Any(x => x.Descriptor.Name.ToUpperInvariant() == nameToUpper);
        }

        public Type NewInstanceHandler 
        { 
            get
            {
                return _dynamicFactory;
            }

            set
            {
                if (value.GetMethods(System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public)
                    .Where(x => x.GetCustomAttributes(false).Any(y => y is ScriptConstructorAttribute))
                    .Any())
                {
                    _dynamicFactory = value;
                }
                else
                {
                    throw new InvalidOperationException("Class " + value.ToString() + " can't be registered as New handler");
                }
            }
        }

        public TypeDescriptor GetTypeDescriptorFor(IValue typeTypeValue)
        {
            if (typeTypeValue.DataType != DataType.Type)
                throw RuntimeException.InvalidArgumentType();

            var ttVal = typeTypeValue.GetRawValue() as TypeTypeValue;

            System.Diagnostics.Debug.Assert(ttVal != null, "value must be of type TypeTypeValue");

            return ttVal.Value;

        }

        #endregion

    }

    public static class TypeManager
    {
        private static ITypeManager _instance;

        internal static void Initialize(ITypeManager instance)
        {
            _instance = instance;
        }

        public static Type GetImplementingClass(int typeId)
        {
            return _instance.GetImplementingClass(typeId);
        }

        public static TypeDescriptor GetTypeByName(string name)
        {
            return _instance.GetTypeByName(name);
        }

        public static TypeDescriptor RegisterType(string name, Type implementingClass)
        {
            return _instance.RegisterType(name, implementingClass);
        }

        public static void RegisterAliasFor(TypeDescriptor td, string alias)
        {
            _instance.RegisterAliasFor(td, alias);
        }

        public static TypeDescriptor GetTypeById(int id)
        {
            var type = _instance.GetTypeById(id);
            return type;
        }

        public static bool IsKnownType(Type type)
        {
            return _instance.IsKnownType(type);
        }

        public static bool IsKnownType(string typeName)
        {
            return _instance.IsKnownType(typeName);
        }

        public static TypeDescriptor GetTypeByFrameworkType(Type type)
        {
            return _instance.GetTypeByFrameworkType(type);
        }

        public static TypeDescriptor GetTypeDescriptorFor(IValue typeTypeValue)
        {
            return _instance.GetTypeDescriptorFor(typeTypeValue);
        }

        public static Type NewInstanceHandler
        {
            get
            {
                return _instance.NewInstanceHandler;
            }
            set
            {
                _instance.NewInstanceHandler = value;
            }
        }

        public static Type GetFactoryFor(string typeName)
        {
            int typeId;
            Type clrType;
            try
            {
                typeId = TypeManager.GetTypeByName(typeName).ID;
                clrType = TypeManager.GetImplementingClass(typeId);
            }
            catch (KeyNotFoundException)
            {
                if (NewInstanceHandler != null)
                {
                    clrType = NewInstanceHandler;
                }
                else
                {
                    throw new RuntimeException("Конструктор не найден (" + typeName + ")");
                }
            }

            return clrType;
        }
    }

}

//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test compilation of all class files.
 */

// 3D includes (MQL5 only).
#ifdef __MQL5__
#include "../3D/Chart3D.h"
#include "../3D/Cube.h"
#include "../3D/Devices/MTDX/MTDXDevice.h"
#include "../3D/Devices/MTDX/MTDXIndexBuffer.h"
#include "../3D/Devices/MTDX/MTDXShader.h"
#include "../3D/Devices/MTDX/MTDXVertexBuffer.h"
#include "../3D/Frontends/MT5Frontend.h"
#endif

// Forward declaration.
struct IndicatorParams;

// Includes.
#include "../Account/AccountMt.h"
#include "../Array.mqh"
#include "../Task/TaskAction.h"
//#include "../BasicTrade.mqh" // @removeme
#include "../Buffer.mqh"
#include "../BufferFXT.mqh"
#include "../BufferStruct.mqh"
#include "../Chart.mqh"
#include "../Collection.mqh"
#include "../Config.mqh"
#include "../Convert.mqh"
#include "../Database.mqh"
#include "../DateTime.mqh"
#include "../Dict.mqh"
#include "../DictBase.mqh"
#include "../DictIteratorBase.mqh"
#include "../DictObject.mqh"
#include "../DictSlot.mqh"
#include "../DictStruct.mqh"
#include "../Draw.mqh"
#include "../DrawIndicator.mqh"
#include "../EA.mqh"
#include "../File.mqh"
// #include "../Inet.mqh"
#include "../Log.mqh"
#include "../MD5.mqh"
#include "../Storage/IValueStorage.h"
#include "../Task/TaskCondition.h"
//#include "../MQL4.mqh" // @removeme
//#include "../MQL5.mqh" // @removeme
#include "../Mail.mqh"
#include "../Market.mqh"
#include "../Math.h"
#include "../Matrix.mqh"
#include "../MiniMatrix.h"
#include "../Msg.mqh"
#include "../Object.mqh"
#include "../Order.mqh"
#include "../Orders.mqh"
#include "../Pattern.mqh"
// #include "../Profiler.mqh"
#include "../Redis.mqh"
#include "../Refs.mqh"
#include "../Registry.mqh"
#include "../RegistryBinary.mqh"
#include "../Report.mqh"
#include "../Storage/Objects.h"
#include "../Storage/ObjectsCache.h"
// #include "../SVG.mqh" // @removeme
#include "../Session.mqh"
#include "../SetFile.mqh"
#include "../Socket.mqh"
#include "../Stats.mqh"
#include "../Std.h"
#include "../Storage/Singleton.h"
#include "../Strategy.mqh"
#include "../String.mqh"
#include "../SummaryReport.mqh"
#include "../SymbolInfo.mqh"
#include "../Task/Task.h"
#include "../Task/TaskAction.h"
#include "../Task/TaskCondition.h"
#include "../Task/TaskGetter.h"
#include "../Task/TaskManager.h"
#include "../Task/TaskObject.h"
#include "../Task/TaskSetter.h"
#include "../Task/Taskable.h"
#include "../Terminal.mqh"
// #include "../Tester.mqh" // @removeme
#include "../Storage/ValueStorage.h"
// #include "../Tests.mqh" // @removeme
#include "../Timer.mqh"
#include "../Trade.mqh"
#include "../Util.h"
#include "../Web.mqh"

// Includes Indicator files.
#include "../Indicator/Indicator.define.h"
#include "../Indicator/Indicator.h"
#include "../Indicator/IndicatorBase.h"
#include "../Indicator/IndicatorData.h"
#include "../Indicators/indicators.h"

// Includes Serializer files.
#include "../Serializer/Serializable.h"
#include "../Serializer/Serializer.h"
#include "../Serializer/SerializerBinary.h"
#include "../Serializer/SerializerConversions.h"
#include "../Serializer/SerializerConverter.h"
#include "../Serializer/SerializerCsv.h"
#include "../Serializer/SerializerDict.h"
#include "../Serializer/SerializerJson.h"
#include "../Serializer/SerializerNode.h"
#include "../Serializer/SerializerNodeIterator.h"
#include "../Serializer/SerializerNodeParam.h"
#include "../Serializer/SerializerObject.h"
#include "../Serializer/SerializerSqlite.h"

/**
 * Implements Init event handler.
 */
int OnInit() { return (_LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED); }

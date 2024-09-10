//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
#include "../Platform/Chart3D/Chart3D.h"
#include "../Platform/Chart3D/Cube.h"
#include "../Platform/Chart3D/Devices/MTDX/MTDXDevice.h"
#include "../Platform/Chart3D/Devices/MTDX/MTDXIndexBuffer.h"
#include "../Platform/Chart3D/Devices/MTDX/MTDXShader.h"
#include "../Platform/Chart3D/Devices/MTDX/MTDXVertexBuffer.h"
#include "../Platform/Chart3D/Frontends/MT5Frontend.h"
#include "../Math/OpenCL.h"
#endif

// Forward declaration.
struct IndicatorParams;

// Includes.
#include "../Exchange/Account/AccountMt.h"
#include "../Storage/Array.h"
#include "../Task/TaskAction.h"
#include "../Storage/Dict/Buffer/Buffer.h"
#include "../Storage/Dict/Buffer/BufferFXT.h"
#include "../Storage/Dict/Buffer/BufferStruct.h"
#include "../Platform/Chart/Chart.h"
#include "../Config.mqh"
#include "../Convert.mqh"
#include "../Storage/Database.h"
#include "../Storage/DateTime.h"
#include "../Storage/Dict/Dict.h"
#include "../Storage/Dict/DictBase.h"
#include "../Storage/Dict/DictIteratorBase.h"
#include "../Storage/Dict/DictObject.h"
#include "../Storage/Dict/DictSlot.h"
#include "../Storage/Dict/DictStruct.h"
#include "../Storage/Instances.h"
#include "../Platform/Plot.h"
#include "../Indicators/DrawIndicator.mqh"
#include "../EA.mqh"
#include "../File.mqh"
#include "../Log.mqh"
#include "../MD5.mqh"
#include "../Storage/IValueStorage.h"
#include "../Task/TaskCondition.h"
#include "../Mail.mqh"
#include "../Market.mqh"
#include "../Math/Math.h"
#include "../Math/Matrix.h"
#include "../Math/MatrixMini.h"
#include "../Storage/Object.h"
#include "../Platform/Order.h"
#include "../Platform/Orders.h"
#include "../Pattern.mqh"
// #include "../Profiler.mqh"
#include "../Storage/Redis.h"
#include "../Refs.mqh"
#include "../Report.mqh"
#include "../Storage/Objects.h"
#include "../Storage/Cache/ObjectsCache.h"
#include "../SetFile.mqh"
#include "../Socket.mqh"
#include "../Std.h"
#include "../Storage/Singleton.h"
#include "../Strategy/Strategy.h"
#include "../Storage/String.h"
#include "../SummaryReport.mqh"
#include "../Exchange/SymbolInfo/SymbolInfo.h"
#include "../Task/Task.h"
#include "../Task/TaskAction.h"
#include "../Task/TaskCondition.h"
#include "../Task/TaskGetter.h"
#include "../Task/TaskManager.h"
#include "../Task/TaskObject.h"
#include "../Task/TaskSetter.h"
#include "../Task/Taskable.h"
#include "../Platform/Terminal.h"
// #include "../Tester.mqh" // @removeme
#include "../Storage/Collection.h"
#include "../Storage/ValueStorage.h"
// #include "../Tests.mqh" // @removeme
#include "../Timer.mqh"
#include "../Trade.mqh"
#include "../Util.h"

// Includes Indicator files.
#include "../Indicator/Indicator.define.h"
#include "../Indicator/Indicator.h"
#include "../Indicator/IndicatorBase.h"
#include "../Indicator/IndicatorData.h"
#include "../Indicator/IndicatorCandle.h"
#include "../Indicator/IndicatorRenko.h"
#include "../Indicator/IndicatorTf.h"
#include "../Indicator/IndicatorTick.h"
#include "../Indicator/IndicatorTickSource.h"
#include "../Indicators/includes.h"

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

#ifndef GLOBAL_PLANNER_CONTEXT_H
#define GLOBAL_PLANNER_CONTEXT_H

#include "hsm/context.h"

using planning_utils::Context;
using planning_utils::ContextPtr;


#define CREATE_GLOBAL_PLANNER_CONTEXT(T, ctx)                                  \
    std::shared_ptr<T> ctx = T::createGlobalPlannerContext()


#define DEFINE_GLOBAL_PLANNER_CONTEXT(T)                                       \
    struct Context##T##Planner : planning_planner::ContextGlobalPlanner     \
    {                                                                          \
      protected:                                                               \
        Context##T##Planner() : planning_planner::ContextGlobalPlanner() {} \
      public:                                                                  \
        static std::shared_ptr<Context##T##Planner> createGlobalPlannerContext()\
        {                                                                      \
            Context##T##Planner *ctx = new Context##T##Planner();              \
            return std::shared_ptr<Context##T##Planner>(ctx);                  \
        }                                                                      \
        Context##T##Planner(const Context##T##Planner &) = delete;             \
        void operator=(const Context##T##Planner &) = delete;                  \
        virtual std::string getTypeName() { return type_name; }                \
        inline static const std::string type_name                              \
            = STR_CONN3(Context, T, Planner);
#define END_GLOBAL_PLANNER_CONTEXT(T)                                          \
    };                                                                         \
    using Context##T##Planner##Ptr = std::shared_ptr<Context##T##Planner>;

namespace planning_planner
{
    DEFINE_CONTEXT(GlobalPlanner)
        int64_t input_id;
    END_CONTEXT(GlobalPlanner);
}

#endif // GLOBAL_PLANNER_CONTEXT_H
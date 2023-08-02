
#ifndef __RIPPLE_OBJECT__
#define __RIPPLE_OBJECT__

#include <iostream>
#include <vector>
using namespace std;
#include "cocos2d.h"
using namespace cocos2d;
#include "cocos-ext.h"
using namespace cocos2d::extension;
#include "ensRippleNode.h"
using namespace ens;

class RippleObject : public Layer
{
public:
   
	RippleObject(){
        m_rippleSprite=NULL;
    }
    virtual ~RippleObject(){
    }
	//touch
	virtual void onTouchesBegan(const std::vector<Touch*>& touches, Event *unused_event);
	virtual void onTouchesMoved(const std::vector<Touch*>& touches, Event *unused_event);
	virtual void onTouchesEnded(const std::vector<Touch*>& touches, Event *unused_event);
    bool init(const char* filename,float gridSideLen = 8.0);
protected:
    CrippleSprite*m_rippleSprite;
};

#endif
